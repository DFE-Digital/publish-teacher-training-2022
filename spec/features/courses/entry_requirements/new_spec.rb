require "rails_helper"

feature "new course entry_requirements", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_entry_requirements_page) do
    PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new
  end
  let(:provider) { build(:provider) }
  let(:level) { :further_education }
  let(:course)  { build(:course, :new, provider: provider, level: level, gcse_subjects_required_using_level: true) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_new_resource(course)
    stub_api_v2_build_course
  end

  context "level further_education" do
    scenario "creating a new course" do
      visit new_provider_recruitment_cycle_courses_entry_requirements_path(
        provider.provider_code,
        recruitment_cycle.year,
      )
      expect(page.status_code).to eq(404)
    end
  end

  context "level primary" do
    let(:level) { :primary }
    before do
      stub_api_v2_build_course(maths: "expect_to_achieve_before_training_begins")
    end

    scenario "creating a new course" do
      visit new_provider_recruitment_cycle_courses_entry_requirements_path(
        provider.provider_code,
        recruitment_cycle.year,
      )

      expect(page.status_code).to eq(200)

      expect(new_entry_requirements_page).to(
        be_displayed(
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code,
        ),
      )

      expect(new_entry_requirements_page).to have_maths_requirements
      expect(new_entry_requirements_page).to have_english_requirements
      expect(new_entry_requirements_page).to have_science_requirements

      %w[
        maths_requirements
        english_requirements
        science_requirements
      ].each do |subject|
        expect(new_entry_requirements_page.send(subject)).to have_field("1. Must have (least flexible)")
        expect(new_entry_requirements_page.send(subject)).to have_field("2: Taking")
        expect(new_entry_requirements_page.send(subject)).to have_field("3: Equivalence test")
      end

      choose("course_maths_expect_to_achieve_before_training_begins")
      click_on "Continue"

      expect(current_path).to eq new_provider_recruitment_cycle_courses_outcome_path(provider.provider_code, provider.recruitment_cycle_year)
    end
  end

  context "level secondary" do
    let(:level) { :secondary }
    before do
      stub_api_v2_build_course(english: "expect_to_achieve_before_training_begins")
    end
    scenario "creating a new course" do
      visit new_provider_recruitment_cycle_courses_entry_requirements_path(
        provider.provider_code,
        recruitment_cycle.year,
      )

      expect(page.status_code).to eq(200)
      expect(new_entry_requirements_page).to(
        be_displayed(
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code,
        ),
      )

      expect(new_entry_requirements_page).to have_maths_requirements
      expect(new_entry_requirements_page).to have_english_requirements
      expect(new_entry_requirements_page).to_not have_science_requirements

      %w[
        maths_requirements
        english_requirements
      ].each do |subject|
        expect(new_entry_requirements_page.send(subject)).to have_field("1. Must have (least flexible)")
        expect(new_entry_requirements_page.send(subject)).to have_field("2: Taking")
        expect(new_entry_requirements_page.send(subject)).to have_field("3: Equivalence test")
      end

      choose("course_english_expect_to_achieve_before_training_begins")
      click_on "Continue"

      expect(current_path).to eq new_provider_recruitment_cycle_courses_outcome_path(provider.provider_code, provider.recruitment_cycle_year)
    end
  end
end
