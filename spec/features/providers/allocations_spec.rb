require "rails_helper"

RSpec.feature "PE allocations" do
  let(:allocations_page) { PageObjects::Page::Providers::Allocations::IndexPage.new }
  let(:allocations_new_page) { PageObjects::Page::Providers::Allocations::NewPage.new }
  let(:allocations_show_page) { PageObjects::Page::Providers::Allocations::ShowPage.new }

  scenario "Accredited body views PE allocations page" do
    given_accredited_body_exists
    given_training_provider_with_pe_fee_founded_course_exists

    given_i_am_signed_in_as_an_admin
    # once the feature is released it should be changed to
    # given_i_am_signed_in_as_a_user_from_the_accredited_body

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page
    and_i_see_only_see_training_providers_offering_pe_fee_founded_courses
    and_i_see_allocations_with_status_and_actions

    and_i_see_correct_breadcrumbs
  end

  scenario "Accredited body views PE allocations page when training provider has no PE fee-founded course" do
    given_accredited_body_exists
    given_there_is_no_training_providers_with_pe_fee_founded_course
    # once the feature is released it should be changed to
    # given_i_am_signed_in_as_a_user_from_the_accredited_body
    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    and_i_do_not_see_request_pe_again_section

    and_i_see_correct_breadcrumbs
  end

  scenario "Accredited body decides to request PE allocations" do
    given_accredited_body_exists
    given_training_provider_with_pe_fee_founded_course_exists

    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page
    and_i_see_only_see_training_providers_offering_pe_fee_founded_courses
    and_i_see_allocations_with_status_and_actions

    when_i_click_confirm_choice
    then_i_see_request_pe_allocations_page

    when_i_click_yes
    and_i_click_continue
    and_i_see_the_corresponding_page_title("Request sent")
  end

  scenario "Accredited body decides not to request PE allocations" do
    given_accredited_body_exists
    given_training_provider_with_pe_fee_founded_course_exists

    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page
    and_i_see_only_see_training_providers_offering_pe_fee_founded_courses
    and_i_see_allocations_with_status_and_actions

    when_i_click_confirm_choice
    then_i_see_request_pe_allocations_page

    when_i_click_no
    and_i_click_continue

    and_i_see_the_confirmation_page
    and_i_see_the_corresponding_page_title("Thank you")
  end

  scenario "Accredited body decides to view request PE allocations confirmation" do
    given_accredited_body_exists
    given_training_provider_with_pe_fee_founded_course_exists

    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    and_i_see_only_see_training_providers_offering_pe_fee_founded_courses
    and_i_see_allocations_with_status_and_actions

    and_i_click_on_first_view_requested_confirmation

    and_i_see_the_confirmation_page
    and_i_see_the_corresponding_page_title("Request sent")
  end

  scenario "Accredited body decides to view request no PE allocations confirmation" do
    given_accredited_body_exists
    given_training_provider_with_pe_fee_founded_course_exists

    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    and_i_see_only_see_training_providers_offering_pe_fee_founded_courses
    and_i_see_allocations_with_status_and_actions

    and_i_click_on_first_view_not_requested_confirmation

    and_i_see_the_confirmation_page
    and_i_see_the_corresponding_page_title("Thank you")
  end

  scenario "There is no PE allocations page for non accredited body" do
    given_a_provider_exists
    given_i_am_signed_in_as_an_admin

    when_i_visit_training_providers_page
    there_is_no_request_pe_courses_link
    and_i_cannot_access_pe_alloacations_page
  end

  scenario "Non-admin user cannot views PE allocations page" do
    given_accredited_body_exists
    given_i_am_signed_in

    when_i_visit_my_organisations_page
    there_is_no_request_pe_courses_link
    and_i_cannot_access_accredited_body_pe_alloacations_page
  end

  scenario "Accredited body views PE allocations request page for training provider" do
    given_accredited_body_exists
    given_training_provider_exists
    given_i_am_signed_in_as_an_admin

    when_i_visit_pe_alloacations_request_page

    then_i_see_the_pe_alloacations_request_page

    and_i_see_back_link
    and_i_see_training_provider_name
    and_i_see_request_form
  end

  def and_i_see_request_form
    request_form = find '[data-qa="allocation__requested"]'

    expect(request_form.find("#requested_no")).to_not be_checked
    expect(request_form.find("#requested_yes")).to_not be_checked
  end

  def and_i_see_training_provider_name
    expect(find("h1")).to have_content(@training_provider.provider_name)
  end

  def then_i_see_the_pe_alloacations_request_page
    expect(page.title).to have_content("Do you want to request PE for this organisation?")
    expect(find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def when_i_visit_pe_alloacations_request_page
    stub_api_v2_resource(@accrediting_body)
    stub_api_v2_resource(@accrediting_body.recruitment_cycle)
    stub_api_v2_resource(@training_provider)

    footer_stub_for_access_request_count

    visit new_provider_recruitment_cycle_allocation_path(@accrediting_body.provider_code, @accrediting_body.recruitment_cycle.year, @training_provider.provider_code)
  end

  def footer_stub_for_access_request_count
    stub_api_v2_resource_collection([build(:access_request)])
  end

  def given_accredited_body_exists
    @accrediting_body = build(:provider, accredited_body?: true)
  end

  def given_i_am_signed_in_as_an_admin
    stub_omniauth(user: build(:user, :admin))
  end

  def when_i_visit_my_organisations_page
    visit provider_path(@accrediting_body.provider_code)
    expect(find("h1")).to have_content(@accrediting_body.provider_name.to_s)
  end

  def and_i_see_back_link
    expect(page).to have_link(
      "Back",
      href: "/organisations/#{@accrediting_body.provider_code}/2020/allocations",
    )
  end

  def given_training_provider_exists
    @training_provider = build(:provider)
  end

  def given_accredited_body_exists
    @accrediting_body = build(:provider, accredited_body?: true)
    stub_api_v2_resource(@accrediting_body.recruitment_cycle)
  end

  def given_i_am_signed_in
    stub_omniauth(user: build(:user))
  end

  def given_i_am_signed_in_as_an_admin
    stub_omniauth(user: build(:user, :admin))
  end

  def given_training_provider_with_pe_fee_founded_course_exists
    @training_provider = build(:provider)
    stub_api_v2_request(
      "/recruitment_cycles/#{@accrediting_body.recruitment_cycle.year}/providers/" \
      "#{@accrediting_body.provider_code}/training_providers" \
      "?filter[funding_type]=fee" \
      "&filter[subjects]=C6" \
      "&recruitment_cycle_year=#{@accrediting_body.recruitment_cycle.year}",
      resource_list_to_jsonapi([@training_provider]),
    )
  end

  def given_there_is_no_training_providers_with_pe_fee_founded_course
    stub_api_v2_request(
      "/recruitment_cycles/#{@accrediting_body.recruitment_cycle.year}/providers/" \
      "#{@accrediting_body.provider_code}/training_providers" \
      "?filter[funding_type]=fee" \
      "&filter[subjects]=C6" \
      "&recruitment_cycle_year=#{@accrediting_body.recruitment_cycle.year}",
      resource_list_to_jsonapi([]),
    )
  end

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(@accrediting_body)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@accrediting_body.provider_code)
    expect(find("h1")).to have_content(@accrediting_body.provider_name.to_s)
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for 2021/22"
  end

  def then_i_see_the_pe_allocations_page
    expect(find("h1")).to have_content("Request PE courses for 2021/22")
  end

  def and_i_see_only_see_training_providers_offering_pe_fee_founded_courses
    expect(allocations_page.rows.first.provider_name.text).to eq(@training_provider.provider_name)
  end

  def and_i_see_allocations_with_status_and_actions
    expect(allocations_page).to have_rows
  end

  def and_i_do_not_see_request_pe_again_section
    expect(allocations_page).not_to have_request_again_header
  end

  def and_i_see_correct_breadcrumbs
    within(".govuk-breadcrumbs") do
      expect(page).to have_link(
        @accrediting_body.provider_name.to_s,
        href: "/organisations/#{@accrediting_body.provider_code}",
      )
      expect(page).to have_content("Request PE courses for 2021/22")
    end
  end

  def given_a_provider_exists
    @provider = build(:provider)
    stub_api_v2_resource(@provider.recruitment_cycle)
  end

  def there_is_no_request_pe_courses_link
    expect(page).not_to have_link("Request PE courses for 2021/22")
  end

  def when_i_visit_training_providers_page
    stub_api_v2_resource(@provider)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@provider.provider_code)
    expect(find("h1")).to have_content(@provider.provider_name.to_s)
  end

  def and_i_cannot_access_pe_alloacations_page
    allocations_page.load(provider_code: @provider.provider_code,
                          recruitment_cycle_year: @provider.recruitment_cycle.year)
    expect(page).to have_content("Page not found")
  end

  def and_i_cannot_access_accredited_body_pe_alloacations_page
    visit provider_recruitment_cycle_allocations_path(@accrediting_body.provider_code, @accrediting_body.recruitment_cycle.year)
    expect(page).to have_content("You are not permitted to see this page")
  end

  def when_i_click_confirm_choice
    stub_api_v2_resource(@training_provider)
    click_on "Confirm choice"
  end

  def then_i_see_request_pe_allocations_page
    expect(find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def when_i_click_yes
    stub_request(:post, "http://localhost:3001/api/v2/providers/#{@accrediting_body.provider_code}/allocations")
      .with(
        body: {
          data: {
            type: "allocations",
            attributes: { provider_id: @training_provider.id },
          },
        }.to_json,
      )

    allocations_new_page.yes.click
  end

  def when_i_click_no
    stub_request(:post, "http://localhost:3001/api/v2/providers/#{@accrediting_body.provider_code}/allocations")
      .with(
        body: {
          data: {
            type: "allocations",
            attributes: { provider_id: @training_provider.id, number_of_places: 0 },
          },
        }.to_json,
      )

    allocations_new_page.no.click
  end

  def and_i_click_continue
    allocations_new_page.continue_button.click
  end

  def and_i_see_the_confirmation_page
    expect(allocations_show_page).to be_displayed
  end

  def and_i_see_the_corresponding_page_title(title)
    expect(allocations_show_page.page_heading).to have_content(title)
  end

  def and_i_click_on_first_view_requested_confirmation
    stub_api_v2_resource(@training_provider)
    allocations_page.view_requested_confirmation_links.first.click
  end

  def and_i_click_on_first_view_not_requested_confirmation
    stub_api_v2_resource(@training_provider)
    allocations_page.view_not_requested_confirmation_links.first.click
  end
end
