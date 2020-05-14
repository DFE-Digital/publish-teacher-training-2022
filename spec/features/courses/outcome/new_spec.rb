require "rails_helper"

feature "new course outcome", type: :feature do
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider, accrediting_provider: build(:provider)) }
  let(:empty_build_course_request) { stub_api_v2_build_course }

  before do
    stub_omniauth
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course(qualification: "qts")
    new_course = build(:course, :new, provider: provider, gcse_subjects_required_using_level: true)
    stub_api_v2_new_resource(new_course)
    empty_build_course_request
  end

  scenario "sends user back to course confirmation" do
    visit_new_outcome_page
    visit_new_outcome_page(goto_confirmation: true)

    new_outcome_page.qualification_fields.qts.choose
    new_outcome_page.continue.click

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  context "Loading the page" do
    scenario "It builds the course on the backend" do
      visit_new_outcome_page

      expect(empty_build_course_request).to have_been_made
    end
  end

  context "Selecting QTS" do
    let(:next_step_page) do
      PageObjects::Page::Organisations::Courses::NewFeeOrSalaryPage.new
    end
    let(:selected_fields) { { qualification: "qts" } }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(qualification: "qts") }

    before do
      visit_new_outcome_page
      build_course_with_selected_value_request
      choose("course_qualification_qts")
      click_on "Continue"
    end

    it_behaves_like "a course creation page"

    context "With an accredited body provider" do
      let(:provider) { build(:provider, accredited_body?: true) }
      let(:next_step_page) do
        PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
      end

      it_behaves_like "a course creation page"
    end
  end

  context "Error handling" do
    let(:course) do
      c = build(:course, provider: provider, qualification: nil)
      c.errors.add(:qualification, "Invalid")
      c
    end

    scenario do
      visit_new_outcome_page
      new_outcome_page.continue.click
      expect(new_outcome_page.error_flash.text).to include("Pick an outcome")
    end
  end

  context "Being provided unexpected edit options" do
    let(:course) do
      build(
        :course,
        :new,
        provider: provider,
        study_mode: "full_time_or_part_time",
        gcse_subjects_required_using_level: true,
        applications_open_from: "2019-10-09",
        start_date: "2019-10-09",
        accrediting_provider: build(:provider),
        level: level,
        edit_options: {
          qualifications: %w[not_a_real_qualification],
        },
      )
    end

    context "With a further education course" do
      let(:level) { :further_education }

      scenario "It raises an exception" do
        expect { visit_new_outcome_page }.to raise_error("QTS qualification options do not match")
      end
    end

    context "With a non further education course" do
      let(:level) { :secondary }

      scenario "It raises an exception" do
        expect { visit_new_outcome_page }.to raise_error("Non QTS qualification options do not match")
      end
    end
  end

private

  def visit_new_outcome_page(**query_params)
    visit new_provider_recruitment_cycle_courses_outcome_path(
      provider.provider_code,
      provider.recruitment_cycle.year,
      query_params,
    )
  end
end
