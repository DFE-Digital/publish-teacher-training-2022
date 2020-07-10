require "rails_helper"

RSpec.feature "PE allocations" do
  let(:do_you_want_page) { PageObjects::Page::Providers::Allocations::EditInitialAllocations::DoYouWantPage.new }
  let(:number_of_places_page) { PageObjects::Page::Providers::Allocations::EditInitialAllocations::NumberOfPlacesPage.new }
  let(:check_answers_page) { PageObjects::Page::Providers::Allocations::EditInitialAllocations::CheckAnswersPage.new }
  let(:confirm_deletion_page) { PageObjects::Page::Providers::Allocations::EditInitialAllocations::ConfirmDeletionPage.new }
  let(:allocations_show_page) { PageObjects::Page::Providers::Allocations::ShowPage.new }

  before do
    allow(Settings).to receive(:allocations_state).and_return("open")
  end

  context "updating an initial allocation" do
    scenario "changing the number of places for an allocation" do
      given_accredited_body_exists
      given_the_accredited_body_has_an_initial_allocation
      given_there_is_a_training_provider_with_previous_allocations
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      and_i_click_change

      then_i_see_do_you_want_page
      and_i_click_continue
      then_i_see_an_error_message

      when_i_select_yes_with_error
      and_i_click_continue
      then_i_see_edit_number_of_places_page

      when_i_fill_in_the_number_of_places_input
      and_i_click_continue
      then_see_the_check_answers_page
      and_the_number_is_the_one_i_entered

      when_i_click_change
      then_i_see_edit_number_of_places_page
      and_i_see_the_updated_number_of_places
      and_i_click_continue

      when_i_click_send_request
      then_i_see_confirmation_page
    end

    scenario "cancelling a request for a new allocation" do
      given_accredited_body_exists
      given_the_accredited_body_has_an_initial_allocation
      given_there_is_a_training_provider_with_previous_allocations
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses
      and_i_click_change

      then_i_see_do_you_want_page

      when_i_select_no
      and_i_click_continue
      then_i_see_the_confirm_deletion_page
    end

    context "validations" do
      context "Accredited body updates number of places" do
        scenario "Accredited body enters nothing" do
          given_accredited_body_exists
          given_the_accredited_body_has_an_initial_allocation
          given_there_is_a_training_provider_with_previous_allocations
          given_i_am_signed_in_as_a_user_from_the_accredited_body

          when_i_visit_my_organisations_page
          and_i_click_request_pe_courses
          and_i_click_change

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_nothing
          and_i_click_continue

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end

        scenario "Accredited body enters '0'" do
          given_accredited_body_exists
          given_the_accredited_body_has_an_initial_allocation
          given_there_is_a_training_provider_with_previous_allocations
          given_i_am_signed_in_as_a_user_from_the_accredited_body

          when_i_visit_my_organisations_page
          and_i_click_request_pe_courses
          and_i_click_change

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_zero
          and_i_click_continue

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end

        scenario "Accredited body enters a float (1.1)" do
          given_accredited_body_exists
          given_the_accredited_body_has_an_initial_allocation
          given_there_is_a_training_provider_with_previous_allocations
          given_i_am_signed_in_as_a_user_from_the_accredited_body

          when_i_visit_my_organisations_page
          and_i_click_request_pe_courses
          and_i_click_change

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_a_float
          and_i_click_continue

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end

        scenario "Accredited body enters a non-numeric character" do
          given_accredited_body_exists
          given_the_accredited_body_has_an_initial_allocation
          given_there_is_a_training_provider_with_previous_allocations
          given_i_am_signed_in_as_a_user_from_the_accredited_body

          when_i_visit_my_organisations_page
          and_i_click_request_pe_courses
          and_i_click_change

          then_i_see_do_you_want_page

          when_i_select_yes
          and_i_click_continue
          then_i_see_edit_number_of_places_page

          when_i_fill_in_the_number_of_places_input_with_a_letter_and_number
          and_i_click_continue

          then_i_see_edit_number_of_places_page
          and_i_see_error_message_that_i_must_enter_a_number
        end
      end
    end
  end

  def given_accredited_body_exists
    @accredited_body = build(:provider, accredited_body?: true)
    stub_api_v2_resource(@accredited_body.recruitment_cycle)
  end

  def given_the_accredited_body_has_an_initial_allocation
    @training_provider_with_allocation = build(:provider)

    @allocation = build(
      :allocation, :initial,
      accredited_body: @accredited_body,
      provider: @training_provider_with_allocation,
      number_of_places: 2
    )

    stub_api_v2_request(
      "/providers/#{@accredited_body.provider_code}/allocations?include=provider,accredited_body",
      resource_list_to_jsonapi([@allocation], include: "provider,accredited_body"),
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{@accredited_body.recruitment_cycle.year}/providers/" \
      "#{@training_provider_with_allocation.provider_code}/show_any" \
      "?recruitment_cycle_year=2020",
      resource_list_to_jsonapi([@training_provider_with_allocation]),
    )
  end

  def user
    @user ||= build(:user)
  end

  def given_i_am_signed_in_as_a_user_from_the_accredited_body
    stub_omniauth(user: user)
  end

  def given_there_is_a_training_provider_with_previous_allocations
    @training_provider = build(:provider)

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

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(@accredited_body)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@accredited_body.provider_code)
    expect(find("h1")).to have_content(@accredited_body.provider_name.to_s)
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for 2021 to 2022"
  end

  def and_i_click_change
    stub_api_v2_request(
      "/allocations/#{@allocation.id}?include=provider,accredited_body",
      resource_list_to_jsonapi([@allocation], include: "provider,accredited_body"),
    )

    click_on "Change"
  end

  def when_i_click_change
    click_on "Change"
  end

  def then_i_see_do_you_want_page
    expect(find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def then_i_see_an_error_message
    expect(page).to have_content("Select one option")
  end

  def when_i_select_yes
    do_you_want_page.yes.click
  end

  def when_i_select_yes_with_error
    choose "Yes"
  end

  def when_i_select_no
    stub_api_v2_request(
      "/allocations/#{@allocation.id}",
      resource_list_to_jsonapi([@allocation]),
      :delete,
    )

    do_you_want_page.no.click
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_edit_number_of_places_page
    expect(find("h1")).to have_content("How many places would you like to request?")
  end

  def when_i_fill_in_the_number_of_places_input
    number_of_places_page.number_of_places_field.fill_in(with: "10")
  end

  def when_i_fill_in_the_number_of_places_input_with_zero
    number_of_places_page.number_of_places_field.fill_in(with: "0")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_float
    number_of_places_page.number_of_places_field.fill_in(with: "1.1")
  end

  def when_i_fill_in_the_number_of_places_input_with_a_letter_and_number
    number_of_places_page.number_of_places_field.fill_in(with: "3a")
  end

  def when_i_fill_in_the_number_of_places_input_with_nothing
    number_of_places_page.number_of_places_field.fill_in(with: "")
  end

  def then_see_the_check_answers_page
    expect(find("h1")).to have_content("Check your information before sending your request")
  end

  def and_the_number_is_the_one_i_entered
    expect(check_answers_page.number_of_places.text).to have_content("10")
  end

  def and_i_see_the_updated_number_of_places
    expect(number_of_places_page.number_of_places_field.value).to have_content("10")
  end

  def when_i_click_send_request
    stub_api_v2_request(
      "/allocations/#{@allocation.id}",
      resource_list_to_jsonapi([@allocation]),
      :patch,
    )

    # Mimicking the setup that the API would go through
    @allocation.request_type = "repeat"
    stub_api_v2_request(
      "/allocations/#{@allocation.id}",
      resource_list_to_jsonapi([@allocation]),
    )

    check_answers_page.send_request_button.click
  end

  def then_i_see_confirmation_page
    expect(allocations_show_page.page_heading).to have_content("Request sent")
  end

  def then_i_see_the_confirm_deletion_page
    expect(find("h1")).to have_content("Thank you")
  end

  def and_i_see_error_message_that_i_must_enter_a_number
    expect(page).to have_content("You must enter a number")
  end
end
