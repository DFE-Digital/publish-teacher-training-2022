require 'rails_helper'

feature 'Edit course entry requirements', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:entry_requirements_page) { PageObjects::Page::Organisations::CourseEntryRequirements.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
      build(:provider).to_jsonapi(include: %i[courses accrediting_provider])
    )

    stub_course_request
    stub_course_details_tab
    entry_requirements_page.load_with_course(course)
  end

  context 'any course' do
    let(:course) do
      build(
        :course,
        provider: provider,
        maths: 'must_have_qualification_at_application_time',
        english: 'expect_to_achieve_before_training_begins',
        science: 'equivalence_test'
      )
    end

    scenario 'can cancel changes' do
      click_on 'Cancel changes'
      expect(course_details_page).to be_displayed
    end

    scenario 'can navigate to the edit screen and back again' do
      course_details_page.load_with_course(course)
      click_on 'Change entry requirements'
      expect(entry_requirements_page).to be_displayed
      click_on 'Back'
      expect(course_details_page).to be_displayed
    end

    scenario 'presents a choice for each subject' do
      expect(entry_requirements_page).to have_maths_requirements
      expect(entry_requirements_page).to have_english_requirements
      expect(entry_requirements_page).to have_science_requirements

      %w[
        maths_requirements
        english_requirements
        science_requirements
      ].each do |subject|
        expect(entry_requirements_page.send(subject)).to have_field('1. Must have (least flexible)')
        expect(entry_requirements_page.send(subject)).to have_field('2: Taking')
        expect(entry_requirements_page.send(subject)).to have_field('3: Equivalence test (recommended)')
        expect(entry_requirements_page.send(subject)).to have_field('No GCSE requirement')
      end
    end

    scenario 'has the correct value selected' do
      expect(entry_requirements_page).to have_maths_requirements
      expect(entry_requirements_page).to have_english_requirements
      expect(entry_requirements_page).to have_science_requirements

      [
        ['maths_requirements', '1. Must have (least flexible)'],
        ['english_requirements', '2: Taking'],
        ['science_requirements', '3: Equivalence test (recommended)']
      ].each do |subject, field_name|
        expect(entry_requirements_page.send(subject)).to have_field(field_name, checked: true)
      end
    end

    scenario 'can be updated' do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      )

      choose('course_maths_expect_to_achieve_before_training_begins')
      choose('course_english_expect_to_achieve_before_training_begins')
      choose('course_science_expect_to_achieve_before_training_begins')
      click_on 'Save'

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content('Your changes have been saved')
      expect(update_course_stub).to have_been_requested
    end
  end

  def stub_course_request
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}/courses" \
      "/#{course.course_code}",
      course.to_jsonapi
    )
  end

  def stub_course_details_tab
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}" \
      "?include=sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: [:sites, :accrediting_provider, :recruitment_cycle, provider: :sites])
    )
  end
end
