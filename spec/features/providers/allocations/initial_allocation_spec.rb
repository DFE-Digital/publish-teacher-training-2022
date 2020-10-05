require "rails_helper"

RSpec.feature "PE allocations" do
  let(:allocations_page) { PageObjects::Page::Providers::Allocations::IndexPage.new }
  let(:number_of_places_page) { PageObjects::Page::Providers::Allocations::NumberOfPlacesPage.new }
  let(:check_your_info_page) { PageObjects::Page::Providers::Allocations::CheckYourInformationPage.new }
  let(:allocations_show_page) { PageObjects::Page::Providers::Allocations::ShowPage.new }

  before do
    allow(Settings.features.allocations).to receive(:state).and_return("open")
  end

  scenario "Accredited body requests new PE allocations" do
    given_accredited_body_exists
    given_the_accredited_body_has_an_allocation
    given_there_is_a_training_provider_with_previous_allocations
    given_i_am_signed_in_as_a_user_from_the_accredited_body

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page
    and_i_should_not_see_training_provider_with_allocations
    and_i_should_not_see_training_provider_with_fee_funded_pe

    and_i_choose_a_training_provider
    and_i_click_continue
    then_i_see_number_of_places_page

    when_i_fill_in_the_number_of_places_input
    and_i_click_continue
    then_i_see_check_your_information_page
    and_the_number_is_the_one_i_entered

    when_i_click_change
    then_i_see_number_of_places_page

    when_i_change_the_number
    and_i_click_continue
    then_i_see_check_your_information_page
    and_the_number_is_the_new_one

    when_i_click_send_request
    then_i_see_confirmation_page
  end

  scenario "Accredited body requests new PE allocations for new training provider" do
    given_accredited_body_exists
    given_the_accredited_body_has_an_allocation
    given_there_is_a_training_provider_with_previous_allocations
    given_i_am_signed_in_as_a_user_from_the_accredited_body

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider
    and_i_click_continue
    then_i_see_pick_a_provider_page

    when_i_click_on_a_provider_from_search_results
    then_i_see_number_of_places_page
    and_i_see_provider_name("Acme SCITT")

    when_i_fill_in_the_number_of_places_input
    and_i_click_continue
    then_i_see_check_your_information_page
    and_the_number_is_the_one_i_entered
  end

  scenario "Accredited body requests new PE allocations for training provider they can't find on first page" do
    given_accredited_body_exists
    given_the_accredited_body_has_an_allocation
    given_there_is_a_training_provider_with_previous_allocations
    given_i_am_signed_in_as_a_user_from_the_accredited_body

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider_that_does_not_exist
    and_i_click_continue
    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_no_providers_exist_for_search
  end

  scenario "Accredited body requests new PE allocations for training provider they can't find on pick a provider page" do
    given_accredited_body_exists
    given_the_accredited_body_has_an_allocation
    given_there_is_a_training_provider_with_previous_allocations
    given_i_am_signed_in_as_a_user_from_the_accredited_body

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider
    and_i_click_continue
    then_i_see_pick_a_provider_page

    when_i_search_again_for_a_training_provider_that_does_not_exist
    and_i_click_search_again
    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_no_providers_exist_for_search
  end

  scenario "Accredited body requests new PE allocations for training provider with empty search" do
    given_accredited_body_exists
    given_the_accredited_body_has_an_allocation
    given_there_is_a_training_provider_with_previous_allocations
    given_i_am_signed_in_as_a_user_from_the_accredited_body

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider_with_empty_string
    and_i_click_continue
    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_i_must_add_more_info
  end

  scenario "Accredited body searches for provider with string containing only one character" do
    given_accredited_body_exists
    given_the_accredited_body_has_an_allocation
    given_there_is_a_training_provider_with_previous_allocations
    given_i_am_signed_in_as_a_user_from_the_accredited_body

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_allocations_page

    when_i_click_choose_an_organisation_button
    then_i_see_the_request_new_pe_allocations_page

    when_i_search_for_a_training_provider_with_string_containing_one_character
    and_i_click_continue
    then_i_see_the_request_new_pe_allocations_page
    and_i_see_error_message_that_my_search_query_must_contain_two_characters
  end

  context "Accredited body enters number of places" do
    scenario "Accredited body submits form without specifying number of places" do
      given_accredited_body_exists
      given_the_accredited_body_has_an_allocation
      given_there_is_a_training_provider_with_previous_allocations
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      then_i_see_the_pe_allocations_page

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue
      then_i_see_number_of_places_page

      and_i_click_continue
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end

    scenario "Accredited body enters '0'" do
      given_accredited_body_exists
      given_the_accredited_body_has_an_allocation
      given_there_is_a_training_provider_with_previous_allocations
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      then_i_see_the_pe_allocations_page

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue
      then_i_see_number_of_places_page

      when_i_fill_in_the_number_of_places_input_with_zero
      and_i_click_continue
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end

    scenario "Accredited body enters a float (1.1)" do
      given_accredited_body_exists
      given_the_accredited_body_has_an_allocation
      given_there_is_a_training_provider_with_previous_allocations
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      then_i_see_the_pe_allocations_page

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue
      then_i_see_number_of_places_page

      when_i_fill_in_the_number_of_places_input_with_a_float
      and_i_click_continue
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end

    scenario "Accredited body enters a non-numeric character" do
      given_accredited_body_exists
      given_the_accredited_body_has_an_allocation
      given_there_is_a_training_provider_with_previous_allocations
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      then_i_see_the_pe_allocations_page

      when_i_click_choose_an_organisation_button
      then_i_see_the_request_new_pe_allocations_page

      and_i_choose_a_training_provider
      and_i_click_continue
      then_i_see_number_of_places_page

      when_i_fill_in_the_number_of_places_input_with_a_letter
      and_i_click_continue
      then_i_see_number_of_places_page
      and_i_see_error_message_that_i_must_enter_a_number
    end
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

  def given_there_is_a_training_provider_with_previous_allocations
    @training_provider = build(:provider)

    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=#{@accredited_body.recruitment_cycle.year}",
      resource_list_to_jsonapi([@training_provider]),
    )

    @training_provider_with_fee_funded_pe = build(:provider)

    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@accredited_body.provider_code}/training_providers" \
      "?filter[funding_type]=fee" \
      "&filter[subjects]=C6",
      resource_list_to_jsonapi([@training_provider_with_fee_funded_pe]),
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@accredited_body.provider_code}/training_providers",
      resource_list_to_jsonapi([@training_provider, @training_provider_with_fee_funded_pe, @training_provider_with_allocation]),
    )
  end

  def given_the_accredited_body_has_an_allocation
    @training_provider_with_allocation = build(:provider)

    @allocation = build(
      :allocation,
      accredited_body: @accredited_body,
      provider: @training_provider_with_allocation,
      number_of_places: 2,
    )

    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?include=provider,accredited_body",
      resource_list_to_jsonapi([@allocation], include: "provider,accredited_body"),
    )
  end

  def user
    @user ||= build(:user)
  end

  def given_i_am_signed_in_as_a_user_from_the_accredited_body
    stub_omniauth(user: user)
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for 2021 to 2022"
  end

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(@accredited_body)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@accredited_body.provider_code)
    expect(find("h1")).to have_content(@accredited_body.provider_name.to_s)
  end

  def then_i_see_the_pe_allocations_page
    expect(find("h1")).to have_content("Request PE courses for 2021 to 2022")
  end

  def when_i_click_choose_an_organisation_button
    click_on "Choose an organisation"
  end

  def then_i_see_the_request_new_pe_allocations_page
    expect(find("h1")).to have_content("Who are you requesting a course for?")
  end

  def and_i_choose_a_training_provider
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?filter[recruitment_cycle_year]=#{@accredited_body.recruitment_cycle.year}&filter[training_provider_code]=#{@training_provider.provider_code}&page[page]=1&page[per_page]=1",
      resource_list_to_jsonapi([]),
    )

    page.choose(@training_provider.provider_name)
  end

  def when_i_search_for_a_training_provider
    stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/providers/suggest_any?query=ACME")
                .to_return(
                  headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
                  body: File.new("spec/fixtures/api_responses/provider-suggestions.json"),
                )

    provider_codes = JSON.parse(File.read("spec/fixtures/api_responses/provider-suggestions.json")).dig("data").map { |p| p["attributes"]["provider_code"] }

    provider_codes.each do |provider_code|
      stub_api_v2_request(
        "/providers/#{@accredited_body.provider_code}/allocations?filter[recruitment_cycle_year]=#{@accredited_body.recruitment_cycle.year}&filter[training_provider_code]=#{provider_code}&page[page]=1&page[per_page]=1",
        resource_list_to_jsonapi([]),
      )
    end

    page.choose("Find an organisation not listed above")
    page.fill_in("training_provider_query", with: "ACME")
  end

  def when_i_click_on_a_provider_from_search_results
    training_provider = build(:provider, provider_code: "A01", provider_name: "Acme SCITT")

    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=#{@accredited_body.recruitment_cycle.year}",
      resource_list_to_jsonapi([training_provider]),
    )

    page.click_on("Acme SCITT")
  end

  def and_i_see_provider_name(provider_name)
    expect(page).to have_content(provider_name)
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_number_of_places_page
    expect(number_of_places_page.header.text).to have_content("How many places would you like to request?")
  end

  def then_i_see_pick_a_provider_page
    expect(find("h1")).to have_content("Pick a provider")
  end

  def and_i_should_not_see_training_provider_with_allocations
    expect(page).to_not have_content(@training_provider_with_allocation.provider_name)
  end

  def and_i_should_not_see_training_provider_with_fee_funded_pe
    expect(page).to_not have_content(@training_provider_with_fee_funded_pe.provider_name)
  end

  def when_i_search_for_a_training_provider_that_does_not_exist
    stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/providers/suggest_any?query=donotexist")
                .to_return(
                  headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
                  body: File.new("spec/fixtures/api_responses/empty-provider-suggestions.json"),
                )

    page.choose("Find an organisation not listed above")
    page.fill_in("training_provider_query", with: "donotexist")
  end

  def and_i_see_error_message_that_no_providers_exist_for_search
    expect(page)
      .to have_content("We could not find this organisation - please check your information and try again.")
  end

  def when_i_search_again_for_a_training_provider_that_does_not_exist
    stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/providers/suggest_any?query=donotexist")
                .to_return(
                  headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
                  body: File.new("spec/fixtures/api_responses/empty-provider-suggestions.json"),
                )

    page.find("span", text: "Try another provider").click
    page.fill_in("training_provider_query", with: "donotexist")
  end

  def and_i_click_search_again
    page.click_on("Search again")
  end

  def when_i_search_for_a_training_provider_with_empty_string
    page.choose("Find an organisation not listed above")
    page.fill_in("training_provider_query", with: "")
  end

  def when_i_search_for_a_training_provider_with_string_containing_one_character
    page.choose("Find an organisation not listed above")
    page.fill_in("training_provider_query", with: "x")
  end

  def and_i_see_error_message_that_i_must_add_more_info
    expect(page).to have_content("You need to add some information")
  end

  def and_i_see_error_message_that_my_search_query_must_contain_two_characters
    expect(page).to have_content("Please enter a minimum of two characters")
  end

  def and_i_see_error_message_that_i_must_enter_a_number
    expect(page).to have_content("You must enter a number")
  end

  def when_i_fill_in_the_number_of_places_input
    number_of_places_page.number_of_places_field.fill_in(with: "2")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_letter
    number_of_places_page.number_of_places_field.fill_in(with: "3a")
  end

  def when_i_fill_in_the_number_of_places_input_with_zero
    number_of_places_page.number_of_places_field.fill_in(with: "0")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_float
    number_of_places_page.number_of_places_field.fill_in(with: "1.1")
  end

  def then_i_see_check_your_information_page
    expect(check_your_info_page.header.text).to have_content("Check your information before sending your request")
  end

  def and_the_number_is_the_one_i_entered
    expect(check_your_info_page.number_of_places.text).to have_content("2")
  end

  def when_i_click_change
    check_your_info_page.change_link.click
  end

  def when_i_change_the_number
    number_of_places_page.number_of_places_field.fill_in(with: "3")
  end

  def and_the_number_is_the_new_one
    expect(check_your_info_page.number_of_places.text).to eq("3")
  end

  def when_i_click_send_request
    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations",
      resource_list_to_jsonapi([@allocation]),
      :post,
    )
    # Mimicking the setup that the API would go through
    @allocation.request_type = "repeat"
    stub_api_v2_request(
      "/allocations/#{@allocation.id}",
      resource_list_to_jsonapi([@allocation]),
    )

    check_your_info_page.send_request_button.click
  end

  def then_i_see_confirmation_page
    expect(allocations_show_page.page_heading).to have_content("Request sent")
  end
end
