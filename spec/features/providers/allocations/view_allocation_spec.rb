require "rails_helper"

RSpec.feature "PE allocations" do
  let(:allocations_page) { PageObjects::Page::Providers::Allocations::IndexPage.new }

  before do
    allow(Settings.features.allocations).to receive(:state).and_return("confirmed")
    allow(Settings).to receive(:allocation_cycle_year).and_return(2022)
  end

  context "when a provider does not have allocations assigned to them" do
    scenario "an accredited body views PE allocations page" do
      given_i_am_signed_in_as_a_user_from_the_accredited_body

      and_i_click_view_allocations
      and_it_has_the_correct_no_allocations_message
      and_i_see_correct_breadcrumbs
    end
  end

  context "When a provider has allocations assigned to them" do
    scenario "an accredited body views PE allocations page" do
      given_i_am_signed_in_as_a_user_from_the_accredited_body
      and_an_allocation_exists_assigned_to_accredited_body

      and_i_click_view_allocations(allocation)
      and_it_has_the_correct_allocations_content
      and_i_see_correct_breadcrumbs
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

  def given_i_am_signed_in_as_a_user_from_the_accredited_body
    signed_in_user(provider: accredited_body)
  end

  def next_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year + 1} to #{Settings.allocation_cycle_year + 2}"
  end

  def and_an_allocation_exists_assigned_to_accredited_body
    allocation
  end

  def and_i_click_view_allocations(response = nil)
    stub_api_v2_request(
      "/providers/#{accredited_body.provider_code}/allocations?filter[recruitment_cycle][year][0]=#{current_recruitment_cycle.year - 1}&filter[recruitment_cycle][year][1]=#{current_recruitment_cycle.year}&include=provider,accredited_body,allocation_uplift",
      resource_list_to_jsonapi([response].compact, include: "provider,accredited_body,allocation_uplift"),
    )
    click_on "View your PE allocations for #{next_allocation_cycle_period_text}"
  end

  def and_it_has_the_correct_no_allocations_message
    expect(allocations_page).to have_content("You did not request any allocations for fee-funded PE courses for #{next_allocation_cycle_period_text}")
  end

  def and_it_has_the_correct_allocations_content
    expect(allocations_page.rows.first.provider_name.text).to eq(training_provider.provider_name)
    expect(allocations_page.rows.first.allocation_number.text.to_i).to eq(allocation.confirmed_number_of_places)
    expect(allocations_page.rows.first.uplift_number.text.to_i).to eq(allocation.allocation_uplift.uplifts)
  end

  def and_i_see_correct_breadcrumbs
    within(".govuk-breadcrumbs") do
      expect(page).to have_link(
        accredited_body.provider_name.to_s,
        href: "/organisations/#{accredited_body.provider_code}",
      )
    end
  end

  def allocation(options = {})
    @allocation ||= build(
      :allocation,
      :with_uplift,
      options[:request_type] || :repeat,
      accredited_body: accredited_body,
      provider: training_provider,
      number_of_places: options[:number_of_places] || 3,
      confirmed_number_of_places: 10,
    )
  end
end
