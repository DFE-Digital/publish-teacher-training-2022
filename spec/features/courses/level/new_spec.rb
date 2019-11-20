require "rails_helper"

feature "New course level", type: :feature do
  let(:new_level_page) do
    PageObjects::Page::Organisations::Courses::NewLevelPage.new
  end
  let(:provider) { build(:provider) }
  let(:course) do
    build(:course,
          :new,
          provider: provider,
          level: :primary,
          study_mode: "full_time_or_part_time",
          gcse_subjects_required_using_level: true,
          applications_open_from: "2019-10-09",
          start_date: "2019-10-09",
          edit_options: {
            subjects: [],
          })
  end

  before do
    stub_omniauth
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_new_resource(course)
    stub_api_v2_build_course
  end

  context "With no validation errors" do
    before do
      stub_api_v2_build_course(is_send: 0, level: "secondary")
      visit_new_level_page
    end

    scenario "sends user back to course confirmation" do
      visit_new_level_page(goto_confirmation: true)

      new_level_page.level_fields.secondary.choose
      new_level_page.continue.click

      expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
    end

    context "Selecting primary" do
      let(:next_step_page) do
        PageObjects::Page::Organisations::Courses::NewSubjectsPage.new
      end
      let(:selected_fields) { { level: "primary", is_send: "0" } }
      let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

      before do
        build_course_with_selected_value_request
        new_level_page.level_fields.primary.click
        new_level_page.continue.click
      end

      it_behaves_like "a course creation page"
    end
  end

  context "Error handling" do
    before do
      stub_api_v2_build_course(is_send: 0)
      visit_new_level_page
    end

    let(:course) do
      c = build(:course, provider: provider, is_send: nil, level: nil)
      c.errors.add(:level, "Invalid")
      c
    end

    scenario do
      new_level_page.continue.click
      expect(new_level_page.error_flash.text).to include("Level Invalid")
    end
  end

private

  def visit_new_level_page(**query_params)
    visit new_provider_recruitment_cycle_courses_level_path(provider.provider_code, provider.recruitment_cycle.year, query_params)
  end
end
