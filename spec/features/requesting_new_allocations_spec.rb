require "rails_helper"

RSpec.feature "PE allocations" do
  let(:allocations_page) { PageObjects::Page::Providers::Allocations::IndexPage.new }

  scenario "Accredited body requests new PE allocations" do
    given_accredited_body_exists
    given_there_is_a_training_provider_without_previous_allocations
    given_the_accredited_body_has_not_requested_renewal_of_an_allocation
    # once the feature is released it should be changed to
    # given_i_am_signed_in_as_a_user_from_the_accredited_body
    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    and_i_choose_a_training_provider
    and_i_click_continue
    then_i_see_number_of_places_page
  end

  scenario "Accredited body requests new PE allocations for new training provider" do
    given_accredited_body_exists
    given_there_is_a_training_provider_without_previous_allocations
    given_the_accredited_body_has_not_requested_renewal_of_an_allocation
    # once the feature is released it should be changed to
    # given_i_am_signed_in_as_a_user_from_the_accredited_body
    given_i_am_signed_in_as_an_admin

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider
    and_i_click_continue
    then_i_see_pick_a_provider_page

    when_i_click_on_a_provider_from_search_results
    and_i_click_continue
    then_i_see_number_of_places_page
    and_i_see_provider_name("Acme SCITT")
  end

  def given_accredited_body_exists
    @accredited_body = build(:provider, accredited_body?: true)
    stub_api_v2_resource(@accredited_body.recruitment_cycle)
  end

  def given_there_is_a_training_provider_without_previous_allocations
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@accredited_body.provider_code}/training_providers" \
      "?filter[funding_type]=fee" \
      "&filter[subjects]=C6" \
      "&recruitment_cycle_year=#{@accredited_body.recruitment_cycle.year}",
      resource_list_to_jsonapi([]),
    )
    @training_provider = build(:provider)
    stub_api_v2_resource(@training_provider)
    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@accredited_body.provider_code}/training_providers" \
      "?recruitment_cycle_year=#{@accredited_body.recruitment_cycle.year}",
      resource_list_to_jsonapi([@training_provider]),
    )
  end

  def given_the_accredited_body_has_not_requested_renewal_of_an_allocation
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?include=provider,accredited_body",
      resource_list_to_jsonapi([], include: "provider,accredited_body"),
    )
  end

  def given_i_am_signed_in_as_an_admin
    stub_omniauth(user: build(:user, :admin))
  end

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(@accredited_body)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@accredited_body.provider_code)
    expect(find("h1")).to have_content(@accredited_body.provider_name.to_s)
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for 2021/22"
  end

  def then_i_see_the_pe_allocations_page
    expect(find("h1")).to have_content("Request PE courses for 2021/22")
  end

  def when_i_click_choose_an_organisation_button
    click_on "Choose an organisation"
  end

  def then_i_see_the_request_new_pe_allocations_page
    expect(find("h1")).to have_content("Who are you requesting a course for?")
  end

  def and_i_choose_a_training_provider
    page.choose(@training_provider.provider_name)
  end

  def when_i_search_for_a_training_provider
    stub_request(:get, "#{Settings.manage_backend.base_url}/api/v2/providers/suggest?query=ACME")
                .to_return(
                  headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
                  body: File.new("spec/fixtures/api_responses/provider-suggestions.json"),
                )

    page.choose("Find an organisation not listed above")
    page.fill_in("training_provider_query", with: "ACME")
  end

  def when_i_click_on_a_provider_from_search_results
    training_provider = build(:provider, provider_code: "A01", provider_name: "Acme SCITT")
    stub_api_v2_resource(training_provider)

    page.choose("Acme SCITT")
  end

  def and_i_see_provider_name(provider_name)
    expect(page).to have_content(provider_name)
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_number_of_places_page
    expect(find("h1")).to have_content("How many places would you like to request?")
  end

  def then_i_see_pick_a_provider_page
    expect(find("h1")).to have_content("Pick a provider")
  end
end
