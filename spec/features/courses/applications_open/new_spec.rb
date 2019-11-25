require "rails_helper"

feature "new course applications open", type: :feature do
  let(:new_applications_open_page) do
    PageObjects::Page::Organisations::Courses::NewApplicationsOpenPage.new
  end

  let(:provider) { build(:provider) }
  let(:course) do
    build(
      :course, :new,
      provider: provider,
      study_mode: "full_time_or_part_time",
      gcse_subjects_required_using_level: true,
      start_date: "2019-10-09"
    )
  end
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(build(:provider, provider_code: "A2"))
    stub_api_v2_resource(build(:provider, provider_code: "A4"))
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_build_course
    stub_api_v2_build_course(applications_open_from: "2018-10-09")
  end

  scenario "sends user to start date page" do
    visit_new_applications_open_page

    expect(new_applications_open_page.applications_open_field).to_not be_checked
    expect(new_applications_open_page.applications_open_field_other).to_not be_checked

    expect(new_applications_open_page.applications_open_field_day.value).to be_nil
    expect(new_applications_open_page.applications_open_field_month.value).to be_nil
    expect(new_applications_open_page.applications_open_field_year.value).to be_nil

    expect(new_applications_open_page).to have_applications_open_field
    expect(new_applications_open_page).to have_applications_open_field_other

    new_applications_open_page.applications_open_field.click
    new_applications_open_page.continue.click

    expect(current_path).to eq new_provider_recruitment_cycle_courses_start_date_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  context "after setting the application open field" do
    let(:course) do
      build(
        :course, :new,
        provider: provider,
        study_mode: "full_time_or_part_time",
        gcse_subjects_required_using_level: true,
        applications_open_from: "2019-10-09",
        start_date: "2019-10-09"
      )
    end

    scenario "sends user back to course confirmation" do
      stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
      visit_new_applications_open_page(goto_confirmation: true)

      new_applications_open_page.applications_open_field.click
      new_applications_open_page.continue.click

      expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
    end
  end

  context "Error handling" do
    let(:course) do
      c = build(:course, provider: provider, start_date: nil)
      c.errors.add(:applications_open_from, "Invalid")
      c
    end

    scenario do
      visit_new_applications_open_page
      new_applications_open_page.applications_open_field.click
      new_applications_open_page.continue.click
      expect(new_applications_open_page.error_flash.text).to include("Applications open from Invalid")
    end
  end

  def visit_new_applications_open_page(**query_params)
    visit signin_path
    visit new_provider_recruitment_cycle_courses_applications_open_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      query_params,
    )
  end
end
