require "rails_helper"

RSpec.feature "PE allocations" do
  let(:allocations_page) { PageObjects::Page::Providers::Allocations::IndexPage.new }
  let(:allocations_new_page) { PageObjects::Page::Providers::Allocations::NewPage.new }
  let(:allocations_show_page) { PageObjects::Page::Providers::Allocations::ShowPage.new }

  before do
    allow(Settings).to receive(:allocations_state).and_return("open")
  end

  context "Repeat allocations" do
    context "Accredited body has previously requested a repeat allocation for a training provider" do
      scenario "Accredited body views PE allocations page" do
        given_accredited_body_exists
        given_training_provider_with_pe_fee_funded_course_exists
        given_the_accredited_body_has_requested_a_repeat_allocation
        given_i_am_signed_in_as_a_user_from_the_accredited_body

        when_i_visit_my_organisations_page
        and_i_click_request_pe_courses

        then_i_see_the_pe_allocations_page
        and_i_see_only_repeat_allocation_statuses
        and_i_see_correct_breadcrumbs
      end
    end

    scenario "Accredited body requests PE allocations" do
      given_accredited_body_exists
      given_training_provider_with_pe_fee_funded_course_exists
      given_the_accredited_body_has_not_requested_an_allocation
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      then_i_see_the_pe_allocations_page
      and_i_see_only_repeat_allocation_statuses

      when_i_click_confirm_choice
      then_i_see_request_pe_allocations_page

      when_i_click_yes
      and_i_click_continue
      and_i_see_the_corresponding_page_title("Request sent")
    end

    scenario "Accredited body decides not to request PE allocations" do
      given_accredited_body_exists
      given_training_provider_with_pe_fee_funded_course_exists
      given_the_accredited_body_has_not_requested_an_allocation
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      then_i_see_the_pe_allocations_page
      and_i_see_only_repeat_allocation_statuses

      when_i_click_confirm_choice
      then_i_see_request_pe_allocations_page

      when_i_click_no
      and_i_click_continue

      and_i_see_the_confirmation_page
      and_i_see_the_corresponding_page_title("Thank you")
    end

    scenario "Accredited body decides to view request PE allocations confirmation" do
      given_accredited_body_exists
      given_training_provider_with_pe_fee_funded_course_exists
      given_the_accredited_body_has_requested_a_repeat_allocation
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses

      then_i_see_the_pe_allocations_page
      and_i_see_only_repeat_allocation_statuses

      and_i_click_on_first_view_requested_confirmation

      and_i_see_the_confirmation_page
      and_i_see_the_corresponding_page_title("Request sent")
    end

    scenario "Accredited body decides to view request no PE allocations confirmation" do
      given_accredited_body_exists
      given_training_provider_with_pe_fee_funded_course_exists
      given_the_accredited_body_has_declined_an_allocation
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses

      then_i_see_the_pe_allocations_page
      and_i_see_only_repeat_allocation_statuses

      and_i_click_on_first_view_not_requested_confirmation

      and_i_see_the_confirmation_page
      and_i_see_the_corresponding_page_title("Thank you")
    end

    scenario "There is no PE allocations page for non accredited body" do
      given_a_provider_exists
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_training_providers_page
      there_is_no_request_pe_courses_link
      and_i_cannot_access_pe_alloacations_page
    end

    scenario "Accredited body views PE allocations request page for training provider" do
      given_accredited_body_exists
      given_training_provider_exists
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_pe_allocations_request_page
      then_i_see_the_pe_allocations_request_page

      and_i_see_back_link
      and_i_see_training_provider_name
      and_i_see_request_form
    end
  end

  context "Initial allocations" do
    context "Accredited body has previously requested an initial allocations for a training provider" do
      scenario "Accredited body views PE allocation page" do
        given_accredited_body_exists
        given_training_provider_with_pe_fee_funded_course_exists
        given_the_accredited_body_has_requested_an_initial_allocation
        given_i_am_signed_in_as_a_user_from_the_accredited_body

        when_i_visit_my_organisations_page
        and_i_click_request_pe_courses

        then_i_see_the_pe_allocations_page
        and_i_see_only_initial_allocation_statuses
        and_i_see_correct_breadcrumbs
      end
    end
  end

  context "Accredited body previously declined a repeat PE allocation" do
    scenario "Accredited body updates an existing PE allocation to 'yes'" do
      given_accredited_body_exists
      given_training_provider_with_pe_fee_funded_course_exists
      given_the_accredited_body_has_declined_an_allocation
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses

      when_i_click_change
      then_i_see_request_pe_allocations_page

      when_i_click_yes_to_update
      and_i_click_continue_to_modify
      and_i_see_the_corresponding_page_title("Request sent")
    end
  end

  context "Accredited body has previously accepted a repeat PE allocation" do
    scenario "Accredited body updates an existing PE allocation to 'no'" do
      given_accredited_body_exists
      given_training_provider_with_pe_fee_funded_course_exists
      given_the_accredited_body_has_requested_a_repeat_allocation
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses

      when_i_click_change
      then_i_see_request_pe_allocations_page

      when_i_click_no_to_update
      and_i_click_continue_to_modify
      and_i_see_the_corresponding_page_title("#{@training_provider.provider_name} Thank you")
    end
  end

private

  def and_i_see_request_form
    expect(allocations_new_page.yes).to_not be_checked
    expect(allocations_new_page.no).to_not be_checked
  end

  def and_i_see_training_provider_name
    expect(find("span.govuk-caption-xl")).to have_content(@training_provider.provider_name)
  end

  def then_i_see_the_pe_allocations_request_page
    expect(page.title).to have_content("Do you want to request PE for this organisation?")
    expect(find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def when_i_visit_pe_allocations_request_page
    stub_api_v2_resource(@accredited_body)
    stub_api_v2_resource(@accredited_body.recruitment_cycle)

    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=2020",
      resource_list_to_jsonapi([@training_provider]),
    )

    footer_stub_for_access_request_count

    visit new_repeat_request_provider_recruitment_cycle_allocation_path(@accredited_body.provider_code, @accredited_body.recruitment_cycle.year, @training_provider.provider_code)
  end

  def footer_stub_for_access_request_count
    stub_api_v2_resource_collection([build(:access_request)])
    stub_api_v2_resource(@training_provider)
  end

  def given_accredited_body_exists
    @accredited_body = build(:provider, accredited_body?: true)
  end

  def when_i_visit_my_organisations_page
    visit provider_path(@accredited_body.provider_code)
    expect(find("h1")).to have_content(@accredited_body.provider_name.to_s)
  end

  def and_i_see_back_link
    expect(page).to have_link(
      "Back",
      href: "/organisations/#{@accredited_body.provider_code}/2020/allocations",
    )
  end

  def given_training_provider_exists
    @training_provider = build(:provider)
  end

  def given_accredited_body_exists
    @accredited_body = build(:provider, accredited_body?: true, users: [user])
    stub_api_v2_resource(@accredited_body.recruitment_cycle)
  end

  def user
    @user ||= build(:user)
  end

  def given_i_am_signed_in_as_a_user_from_the_accredited_body
    stub_omniauth(user: user)
  end

  def given_training_provider_with_pe_fee_funded_course_exists
    @training_provider = build(:provider)
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@accredited_body.provider_code}/training_providers" \
      "?filter[funding_type]=fee" \
      "&filter[subjects]=C6",
      resource_list_to_jsonapi([@training_provider]),
    )
  end

  def given_there_are_no_training_providers_with_pe_fee_funded_course
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@accredited_body.provider_code}/training_providers" \
      "?filter[funding_type]=fee" \
      "&filter[subjects]=C6",
      resource_list_to_jsonapi([]),
    )
  end

  def given_the_accredited_body_has_not_requested_an_allocation
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?include=provider,accredited_body",
      resource_list_to_jsonapi([], include: "provider,accredited_body"),
    )
  end

  def given_the_accredited_body_has_declined_an_allocation
    @allocation = build(:allocation, :declined, accredited_body: @accredited_body, provider: @training_provider, number_of_places: 0)
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?include=provider,accredited_body",
      resource_list_to_jsonapi([@allocation], include: "provider,accredited_body"),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=2020",
      resource_list_to_jsonapi([@training_provider]),
    )
    stub_api_v2_resource(@allocation)
  end

  def given_the_accredited_body_has_requested_a_repeat_allocation
    @allocation = build(:allocation, :repeat, accredited_body: @accredited_body, provider: @training_provider, number_of_places: 1)
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?include=provider,accredited_body",
      resource_list_to_jsonapi([@allocation], include: "provider,accredited_body"),
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=2020",
      resource_list_to_jsonapi([@training_provider]),
    )

    stub_api_v2_resource(@allocation)
  end

  def given_the_accredited_body_has_requested_an_initial_allocation
    initial_allocation = build(:allocation, :initial, accredited_body: @accredited_body, provider: @training_provider, number_of_places: 1)
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?include=provider,accredited_body",
      resource_list_to_jsonapi([initial_allocation], include: "provider,accredited_body"),
    )
  end

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(@accredited_body)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@accredited_body.provider_code)
    expect(find("h1")).to have_content(@accredited_body.provider_name.to_s)
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for 2021 – 2022"
  end

  def then_i_see_the_pe_allocations_page
    expect(find("h1")).to have_content("Request PE courses for 2021 – 2022")
  end

  def and_i_see_only_repeat_allocation_statuses
    expect(allocations_page).to have_repeat_allocations_table
    expect(allocations_page).to_not have_initial_allocations_table
    expect(allocations_page.rows.first.provider_name.text).to eq(@training_provider.provider_name)
  end

  def and_i_see_only_initial_allocation_statuses
    expect(allocations_page).to have_initial_allocations_table
    expect(allocations_page).to_not have_repeat_allocations_table
    expect(allocations_page.rows.first.provider_name.text).to eq(@training_provider.provider_name)
  end

  def and_i_do_not_see_request_pe_again_section
    expect(allocations_page).not_to have_request_again_header
  end

  def and_i_see_correct_breadcrumbs
    within(".govuk-breadcrumbs") do
      expect(page).to have_link(
        @accredited_body.provider_name.to_s,
        href: "/organisations/#{@accredited_body.provider_code}",
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
    allocations_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle.year,
    )
    expect(page).to have_content("Page not found")
  end

  def and_i_cannot_access_accredited_body_pe_allocations_page
    visit provider_recruitment_cycle_allocations_path(@accredited_body.provider_code, @accredited_body.recruitment_cycle.year)
    expect(page).to have_content("You are not permitted to see this page")
  end

  def when_i_click_confirm_choice
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=2020",
      resource_list_to_jsonapi([@training_provider]),
    )

    click_on "Confirm choice"
  end

  def then_i_see_request_pe_allocations_page
    expect(find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def allocation(options = {})
    @allocation ||= build(
      :allocation,
      options[:request_type] || :repeat,
      accredited_body: @accredited_body,
      provider: @training_provider,
      number_of_places: options[:number_of_places] || 3,
    )
  end

  def when_i_click_yes
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations",
      resource_list_to_jsonapi([allocation]),
      :post,
    )

    allocations_new_page.yes.click
  end

  def when_i_click_yes_to_update
    @returned_allocation = build(:allocation, :repeat, id: @allocation.id, accredited_body: @accredited_body, provider: @training_provider, number_of_places: 1)
    stub_request(:patch, "http://localhost:3001/api/v2/allocations/#{@allocation.id}")
      .with(
        body: {
          data: {
            id: @allocation.id,
            type: "allocations",
            attributes: { request_type: "repeat" },
          },
        }.to_json,
      ).to_return(
        headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
        body: File.new("spec/fixtures/api_responses/repeat-allocation.json"),
      )

    allocations_new_page.yes.click
  end

  def when_i_click_no
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations",
      resource_list_to_jsonapi([allocation(request_type: :declined, number_of_places: 0)]),
      :post,
    )

    allocations_new_page.no.click
  end

  def when_i_click_no_to_update
    @returned_allocation = build(:allocation, :declined, id: @allocation.id, accredited_body: @accredited_body, provider: @training_provider, number_of_places: 1)
    stub_request(:patch, "http://localhost:3001/api/v2/allocations/#{@allocation.id}")
      .with(
        body: {
          data: {
            id: @allocation.id,
            type: "allocations",
            attributes: { request_type: "declined" },
          },
        }.to_json,
      ).to_return(
        headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
        body: File.new("spec/fixtures/api_responses/declined-allocation.json"),
      )

    allocations_new_page.no.click
  end

  def when_i_click_change
    stub_api_v2_resource(@allocation, include: "provider,accredited_body")

    click_on "Change"
  end

  def and_i_click_continue_to_modify
    stub_api_v2_request(
      "/allocations/#{@returned_allocation.id}",
      resource_list_to_jsonapi([@returned_allocation]),
    )

    allocations_new_page.continue_button.click
  end

  def and_i_click_continue
    stub_api_v2_request(
      "/allocations/#{allocation.id}",
      resource_list_to_jsonapi([allocation]),
    )

    allocations_new_page.continue_button.click
  end

  def and_i_see_the_confirmation_page
    expect(allocations_show_page).to be_displayed
  end

  def and_i_see_the_corresponding_page_title(title)
    expect(allocations_show_page.page_heading).to have_content(title)
  end

  def and_i_click_on_first_view_requested_confirmation
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=2020",
      resource_list_to_jsonapi([@training_provider]),
    )

    stub_api_v2_request(
      "/allocations/#{@allocation.id}",
      resource_list_to_jsonapi([@allocation]),
    )
    allocations_page.view_requested_confirmation_links.first.click
  end

  def and_i_click_on_first_view_not_requested_confirmation
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=2020",
      resource_list_to_jsonapi([@training_provider]),
    )

    stub_api_v2_request(
      "/allocations/#{@allocation.id}",
      resource_list_to_jsonapi([@allocation]),
    )
    allocations_page.view_not_requested_confirmation_links.first.click
  end
end
