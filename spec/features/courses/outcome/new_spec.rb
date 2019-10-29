require "rails_helper"

feature "new course outcome", type: :feature do
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }
  let(:empty_build_course_request) { stub_api_v2_build_course }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider, gcse_subjects_required_using_level: true)
    stub_api_v2_new_resource(new_course)
    empty_build_course_request

    visit_new_outcome_page
  end

  context "Loading the page" do
    scenario "It builds the course on the backend" do
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

private

  def visit_new_outcome_page
    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/outcome/new"
  end
end
