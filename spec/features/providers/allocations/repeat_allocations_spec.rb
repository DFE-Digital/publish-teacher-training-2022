require "rails_helper"

RSpec.feature "PE allocations" do
  let(:allocations_page) { PageObjects::Page::Providers::Allocations::IndexPage.new }
  let(:allocations_new_page) { PageObjects::Page::Providers::Allocations::NewPage.new }
  let(:allocations_show_page) { PageObjects::Page::Providers::Allocations::ShowPage.new }

  before do
    allow(Settings.features.allocations).to receive(:state).and_return("open")
  end

  context "Repeat allocations" do
    context "Accredited body has previously requested a repeat allocation for a training provider" do
      scenario "Accredited body views PE allocations page" do
        given_i_am_signed_in_as_a_user_from_the_accredited_body
        and_accredited_body_has_previous_allocation_and_has_current_repeat_allocation

        when_i_visit_my_organisations_page
        and_i_click_request_pe_courses

        then_i_see_the_pe_allocations_page
        and_i_see_only_repeat_allocation_statuses
        and_i_see_correct_breadcrumbs
      end
    end

    scenario "Accredited body requests PE allocations" do
      given_i_am_signed_in_as_a_user_from_the_accredited_body
      and_accredited_body_has_previous_allocation_and_has_no_current_allocation

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
      given_i_am_signed_in_as_a_user_from_the_accredited_body
      and_accredited_body_has_previous_allocation_and_has_no_current_allocation

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

    scenario "There is no PE allocations page for non accredited body" do
      given_i_am_signed_in_as_a_user_from_the_training_provider

      when_i_visit_training_providers_page
      there_is_no_request_pe_courses_link
      and_i_cannot_access_pe_allocations_page
    end

    scenario "Accredited body views PE allocations request page for training provider" do
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
        given_i_am_signed_in_as_a_user_from_the_accredited_body
        and_accredited_body_has_previous_allocation_and_has_current_initial_allocation

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
      given_i_am_signed_in_as_a_user_from_the_accredited_body
      and_accredited_body_has_previous_allocation_and_has_current_declined_allocation

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses

      when_i_click_change_for_the_declined_allocation
      then_i_see_request_pe_allocations_page

      when_i_click_yes_to_update_declined_allocation
      and_i_click_continue_to_modify(allocation_to_modify: declined_allocation)
      and_i_see_the_corresponding_page_title("Request sent")
    end
  end

  context "Accredited body has previously accepted a repeat PE allocation" do
    scenario "Accredited body updates an existing PE allocation to 'no'" do
      given_i_am_signed_in_as_a_user_from_the_accredited_body
      and_accredited_body_has_previous_allocation_and_has_current_repeat_allocation

      when_i_visit_my_organisations_page
      and_i_click_request_pe_courses

      when_i_click_change_for_the_repeat_allocation
      then_i_see_request_pe_allocations_page

      when_i_click_no_to_update_repeat_allocation
      and_i_click_continue_to_modify(allocation_to_modify: repeat_allocation)
      and_i_see_the_corresponding_page_title("#{training_provider.provider_name} Thank you")
    end
  end

private

  def current_recruitment_cycle
    @current_recruitment_cycle ||= build(:recruitment_cycle)
  end

  def accredited_body
    @accredited_body ||= build(:provider, accredited_body?: true,
                                          recruitment_cycle: current_recruitment_cycle)
  end

  def training_provider_code
    @training_provider_code ||= "TP1"
  end

  def training_provider
    @training_provider ||= build(:provider, provider_code: training_provider_code, recruitment_cycle: current_recruitment_cycle)
  end

  def previous_recruitment_cycle
    @previous_recruitment_cycle ||= build(:recruitment_cycle, :previous_cycle)
  end

  def previous_training_provider
    @previous_training_provider ||= build(:provider, provider_code: training_provider_code, recruitment_cycle: previous_recruitment_cycle)
  end

  def previous_allocation
    @previous_allocation ||= build(:allocation, provider: previous_training_provider, accredited_body: accredited_body)
  end

  def declined_allocation
    @declined_allocation ||= build(:allocation, :declined, accredited_body: accredited_body, provider: training_provider, number_of_places: 0)
  end

  def repeat_allocation
    @repeat_allocation ||= build(:allocation, :repeat, accredited_body: accredited_body, provider: training_provider, number_of_places: 1)
  end

  def initial_allocation
    @initial_allocation ||= build(:allocation, :initial, accredited_body: accredited_body, provider: training_provider,
                                                         number_of_places: 1)
  end

  def and_i_see_request_form
    expect(allocations_new_page.yes).to_not be_checked
    expect(allocations_new_page.no).to_not be_checked
  end

  def and_i_see_training_provider_name
    expect(find("span.govuk-caption-xl")).to have_content(training_provider.provider_name)
  end

  def then_i_see_the_pe_allocations_request_page
    expect(page.title).to have_content("Do you want to request PE for this organisation?")
    expect(find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def when_i_visit_pe_allocations_request_page
    stub_api_v2_resource(accredited_body)
    stub_api_v2_resource(current_recruitment_cycle)

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/" \
      "#{training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=#{current_recruitment_cycle.year}",
      resource_list_to_jsonapi([training_provider]),
    )

    footer_stub_for_access_request_count

    visit new_repeat_request_provider_recruitment_cycle_allocation_path(accredited_body.provider_code, current_recruitment_cycle.year, training_provider.provider_code)
  end

  def footer_stub_for_access_request_count
    stub_api_v2_resource_collection([build(:access_request)])
  end

  def when_i_visit_my_organisations_page
    visit provider_path(accredited_body.provider_code)
    expect(find("h1")).to have_content(accredited_body.provider_name.to_s)
  end

  def and_i_see_back_link
    expect(page).to have_link(
      "Back",
      href: "/organisations/#{accredited_body.provider_code}/#{current_recruitment_cycle.year}/allocations",
    )
  end

  def given_i_am_signed_in_as_a_user_from_the_accredited_body
    signed_in_user(provider: accredited_body)
  end

  def given_i_am_signed_in_as_a_user_from_the_training_provider
    signed_in_user(provider: training_provider)
  end

  def and_accredited_body_has_previous_allocation(current_allocation: nil)
    stub_api_v2_request(
      "/providers/#{accredited_body.provider_code}/allocations?filter[recruitment_cycle][year][0]=#{previous_recruitment_cycle.year}&filter[recruitment_cycle][year][1]=#{current_recruitment_cycle.year}&include=provider,accredited_body",
      resource_list_to_jsonapi([previous_allocation, current_allocation].compact, include: "provider,accredited_body"),
    )
  end

  alias_method :and_accredited_body_has_previous_allocation_and_has_no_current_allocation, :and_accredited_body_has_previous_allocation

  def and_accredited_body_has_previous_allocation_and_has(current_allocation:)
    and_accredited_body_has_previous_allocation(current_allocation: current_allocation)
  end

  def and_accredited_body_has_previous_allocation_and_has_current_initial_allocation
    and_accredited_body_has_previous_allocation(current_allocation: initial_allocation)
  end

  def and_accredited_body_has_previous_allocation_and_has_current_repeat_allocation
    and_accredited_body_has_previous_allocation(current_allocation: repeat_allocation)
  end

  def and_accredited_body_has_previous_allocation_and_has_current_declined_allocation
    and_accredited_body_has_previous_allocation(current_allocation: declined_allocation)
  end

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(accredited_body)
    footer_stub_for_access_request_count

    visit provider_path(accredited_body.provider_code)
    expect(find("h1")).to have_content(accredited_body.provider_name.to_s)
  end

  def next_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year + 1} to #{Settings.allocation_cycle_year + 2}"
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for #{next_allocation_cycle_period_text}"
  end

  def then_i_see_the_pe_allocations_page
    expect(find("h1")).to have_content("Request PE courses for #{next_allocation_cycle_period_text}")
  end

  def and_i_see_only_repeat_allocation_statuses
    expect(allocations_page).to have_repeat_allocations_table
    expect(allocations_page).to_not have_initial_allocations_table
    expect(allocations_page.rows.first.provider_name.text).to eq(training_provider.provider_name)
  end

  def and_i_see_only_initial_allocation_statuses
    expect(allocations_page).to have_initial_allocations_table
    expect(allocations_page).to_not have_repeat_allocations_table
    expect(allocations_page.rows.first.provider_name.text).to eq(training_provider.provider_name)
  end

  def and_i_do_not_see_request_pe_again_section
    expect(allocations_page).not_to have_request_again_header
  end

  def and_i_see_correct_breadcrumbs
    within(".govuk-breadcrumbs") do
      expect(page).to have_link(
        accredited_body.provider_name.to_s,
        href: "/organisations/#{accredited_body.provider_code}",
      )
      expect(page).to have_content("Request PE courses for #{next_allocation_cycle_period_text}")
    end
  end

  def there_is_no_request_pe_courses_link
    expect(page).not_to have_link("Request PE courses")
  end

  def when_i_visit_training_providers_page
    footer_stub_for_access_request_count

    visit provider_path(training_provider.provider_code)
    expect(find("h1")).to have_content(training_provider.provider_name.to_s)
  end

  def and_i_cannot_access_pe_allocations_page
    allocations_page.load(
      provider_code: training_provider.provider_code,
      recruitment_cycle_year: current_recruitment_cycle.year,
    )
    expect(page).to have_content("Page not found")
  end

  def and_i_cannot_access_accredited_body_pe_allocations_page
    visit provider_recruitment_cycle_allocations_path(accredited_body.provider_code, current_recruitment_cycle.year)
    expect(page).to have_content("You are not permitted to see this page")
  end

  def when_i_click_confirm_choice
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/" \
      "#{training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=#{current_recruitment_cycle.year}",
      resource_list_to_jsonapi([training_provider]),
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
      accredited_body: accredited_body,
      provider: training_provider,
      number_of_places: options[:number_of_places] || 3,
    )
  end

  def when_i_click_yes
    stub_api_v2_request(
      "/providers/#{accredited_body.provider_code}/allocations",
      resource_list_to_jsonapi([allocation]),
      :post,
    )

    allocations_new_page.yes.click
  end

  def when_i_click_yes_to_update_declined_allocation
    update_allocation(allocation_to_update: declined_allocation, request_type: "repeat")

    allocations_new_page.yes.click
  end

  def when_i_click_no_to_update_repeat_allocation
    update_allocation(allocation_to_update: repeat_allocation, request_type: "declined")
    allocations_new_page.no.click
  end

  def when_i_click_no
    stub_api_v2_request(
      "/providers/#{accredited_body.provider_code}/allocations",
      resource_list_to_jsonapi([allocation(request_type: :declined, number_of_places: 0)]),
      :post,
    )

    allocations_new_page.no.click
  end

  def update_allocation(allocation_to_update:, request_type:)
    allocation_to_update.request_type = request_type
    stub_request(:patch, "http://localhost:3001/api/v2/allocations/#{allocation_to_update.id}")
      .with(
        body: {
          data: {
            id: allocation_to_update.id,
            type: "allocations",
            attributes: { request_type: request_type },
          },
        }.to_json,
      ).to_return(
        headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
        body: resource_list_to_jsonapi([allocation_to_update]).to_json,
      )
  end

  def when_i_click_change_for_the_declined_allocation
    when_i_click_change(allocation_to_change: declined_allocation)
  end

  def when_i_click_change_for_the_repeat_allocation
    when_i_click_change(allocation_to_change: repeat_allocation)
  end

  def when_i_click_change(allocation_to_change:)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/" \
      "#{training_provider.provider_code}/show_any" \
      "?recruitment_cycle_year=#{current_recruitment_cycle.year}",
      resource_list_to_jsonapi([training_provider]),
    )

    stub_api_v2_resource(allocation_to_change, include: "provider,accredited_body")

    click_on "Change"
  end

  def and_i_click_continue_to_modify(allocation_to_modify:)
    stub_api_v2_request(
      "/allocations/#{allocation_to_modify.id}",
      resource_list_to_jsonapi([allocation_to_modify]),
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
end
