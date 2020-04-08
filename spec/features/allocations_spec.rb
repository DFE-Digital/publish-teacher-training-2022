require "rails_helper"

RSpec.feature "PE allocations" do
  scenario "Accredited provider views PE allocations page" do
    given_accredited_body_exists
    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_alloacations_page

    and_i_see_correct_breadcrumbs
  end

  scenario "There is no PE allocations page for non accredited body" do
    given_training_provider_exists
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

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(@accrediting_body)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@accrediting_body.provider_code)
    expect(find("h1")).to have_content(@accrediting_body.provider_name.to_s)
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for 2021/22"
  end

  def then_i_see_the_pe_alloacations_page
    expect(find("h1")).to have_content("Request PE courses for 2021/22")
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

  def given_training_provider_exists
    @training_provider = build(:provider)
    stub_api_v2_resource(@training_provider.recruitment_cycle)
  end

  def there_is_no_request_pe_courses_link
    expect(page).not_to have_link("Request PE courses for 2021/22")
  end

  def when_i_visit_training_providers_page
    stub_api_v2_resource(@training_provider)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@training_provider.provider_code)
    expect(find("h1")).to have_content(@training_provider.provider_name.to_s)
  end

  def and_i_cannot_access_pe_alloacations_page
    visit provider_recruitment_cycle_allocations_path(@training_provider.provider_code, @training_provider.recruitment_cycle.year)
    expect(page).to have_content("Page not found")
  end

  def and_i_cannot_access_accredited_body_pe_alloacations_page
    visit provider_recruitment_cycle_allocations_path(@accrediting_body.provider_code, @accrediting_body.recruitment_cycle.year)
    expect(page).to have_content("You are not permitted to see this page")
  end
end