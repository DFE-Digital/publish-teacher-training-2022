require "rails_helper"

feature "new course entry_requirements", type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_entry_requirements_page) do
    PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new
  end
  let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site)]) }
  let(:level) { :further_education }
  let(:course)  do
    build(:course,
          :new,
          provider: provider,
          level: level,
          gcse_subjects_required_using_level: true,
          study_mode: "full_time",
          applications_open_from: "2019-10-09",
          start_date: "2019-10-09")
  end

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "sites")
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_new_resource(course)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
  end

  context "level primary" do
    let(:level) { :primary }
    before do
      stub_api_v2_build_course(
        maths: "expect_to_achieve_before_training_begins",
        english: "expect_to_achieve_before_training_begins",
        science: "expect_to_achieve_before_training_begins",
      )
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
        expect(new_entry_requirements_page.send(subject)).to have_field("1. Must have the GCSE (least flexible)")
        expect(new_entry_requirements_page.send(subject)).to have_field("2: Taking the GCSE")
        expect(new_entry_requirements_page.send(subject)).to have_field("3: Equivalence test")
      end

      choose("course_maths_expect_to_achieve_before_training_begins")
      choose("course_english_expect_to_achieve_before_training_begins")
      choose("course_science_expect_to_achieve_before_training_begins")
      click_on "Continue"

      expect(current_path).to eq new_provider_recruitment_cycle_courses_applications_open_path(provider.provider_code, provider.recruitment_cycle_year)
    end
  end

  context "level secondary" do
    let(:level) { :secondary }
    before do
      stub_api_v2_build_course(
        maths: "expect_to_achieve_before_training_begins",
        english: "expect_to_achieve_before_training_begins",
      )
    end
    scenario "creating a new course" do
      visit_new_entry_requirements

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
        expect(new_entry_requirements_page.send(subject)).to have_field("1. Must have the GCSE (least flexible)")
        expect(new_entry_requirements_page.send(subject)).to have_field("2: Taking the GCSE")
        expect(new_entry_requirements_page.send(subject)).to have_field("3: Equivalence test")
      end

      choose("course_english_expect_to_achieve_before_training_begins")
      choose("course_maths_expect_to_achieve_before_training_begins")
      click_on "Continue"

      expect(current_path).to eq new_provider_recruitment_cycle_courses_applications_open_path(provider.provider_code, provider.recruitment_cycle_year)
    end

    scenario "sends user back to course confirmation" do
      visit_new_entry_requirements(goto_confirmation: true)

      choose("course_english_expect_to_achieve_before_training_begins")
      choose("course_maths_expect_to_achieve_before_training_begins")
      new_entry_requirements_page.continue.click

      expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
    end
  end

  context "Going back" do
    let(:level) { :primary }
    before { visit_new_entry_requirements }

    context "With an accredited body" do
      context "With a single site" do
        let(:new_study_mode_page) { PageObjects::Page::Organisations::Courses::NewStudyModePage.new }

        it "Returns to the study mode page" do
          new_entry_requirements_page.back.click
          expect(new_study_mode_page).to be_displayed
        end
      end

      context "with multiple sites" do
        let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site), build(:site)]) }
        let(:new_locations_page) { PageObjects::Page::Organisations::Courses::NewLocationsPage.new }

        it "Returns to the locations page" do
          new_entry_requirements_page.back.click
          expect(new_locations_page).to be_displayed
        end
      end
    end

    context "With an non accredited body" do
      let(:provider) { build(:provider, accredited_body?: false) }
      let(:new_accredited_body_page) { PageObjects::Page::Organisations::Courses::NewAccreditedBodyPage.new }

      it "Returns to the accredited body page" do
        new_entry_requirements_page.back.click
        expect(new_accredited_body_page).to be_displayed
      end
    end
  end

  context "Error handling" do
    let(:course) do
      c = build(:course,
                provider: provider,
                level: :primary,
                gcse_subjects_required_using_level: true,
                maths: nil,
                english: nil,
                science: nil)
      c.errors.add(:maths, "Invalid")
      c.errors.add(:english, "Invalid")
      c.errors.add(:science, "Invalid")
      c
    end

    scenario do
      visit_new_entry_requirements
      new_entry_requirements_page.continue.click
      expect(new_entry_requirements_page.error_flash.text).to include("Pick an option for Maths")
      expect(new_entry_requirements_page.error_flash.text).to include("Pick an option for English")
      expect(new_entry_requirements_page.error_flash.text).to include("Pick an option for Science")
    end
  end

  def visit_new_entry_requirements(**query_params)
    visit signin_path
    visit new_provider_recruitment_cycle_courses_entry_requirements_path(
      provider.provider_code,
      recruitment_cycle.year,
      query_params,
    )
  end
end
