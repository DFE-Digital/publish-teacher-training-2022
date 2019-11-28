require "rails_helper"

feature "New course start date", type: :feature do
  let(:new_start_date_page) { PageObjects::Page::Organisations::CourseStartDate.new }
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_new_resource(course)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
    stub_api_v2_build_course(start_date: "September #{Settings.current_cycle}")
  end

  scenario "choose course start date" do
    visit_new_start_date_page

    select "September #{Settings.current_cycle}"
    click_on "Continue"

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  scenario "sends user back to course confirmation" do
    visit_new_start_date_page(goto_confirmation: true)

    select "September #{Settings.current_cycle}"
    new_start_date_page.continue.click

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  context "Error handling" do
    let(:course) do
      c = build(:course, provider: provider, start_date: nil)
      c.errors.add(:start_date, "Invalid")
      c
    end

    scenario do
      visit_new_start_date_page
      select "September #{Settings.current_cycle}"
      new_start_date_page.continue.click
      expect(new_start_date_page.error_flash.text).to include("Start date Invalid")
    end
  end

private

  def visit_new_start_date_page(**query_params)
    visit new_provider_recruitment_cycle_courses_start_date_path(
      provider.provider_code,
      provider.recruitment_cycle.year,
      query_params,
    )
  end
end
