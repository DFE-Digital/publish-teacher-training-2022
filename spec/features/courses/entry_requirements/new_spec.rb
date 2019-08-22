require "rails_helper"

feature 'new course entry_requirements', type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_entry_requirements_page) do
    PageObjects::Page::Organisations::Courses::NewEntryRequirementsPage.new
  end
  let(:provider) { build(:provider) }
  let(:level) { :further_education }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider, level: level, gcse_subjects_required_using_level: true)
    stub_api_v2_new_resource(new_course)
  end

  context 'level further_education' do
    scenario 'creating a new course' do
      visit "/organisations/#{provider.provider_code}/#{recruitment_cycle.year}" \
      "/courses/entry_requirements/new"
      expect(page.status_code).to eq(404)
    end
  end

  context 'level primary' do
    let(:level) { :primary }
    scenario 'creating a new course' do
      visit "/organisations/#{provider.provider_code}/#{recruitment_cycle.year}" \
      "/courses/entry_requirements/new"

      expect(page.status_code).to eq(200)

      expect(new_entry_requirements_page).to(
        be_displayed(
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code
        )
      )

      expect(new_entry_requirements_page).to have_maths_requirements
      expect(new_entry_requirements_page).to have_english_requirements
      expect(new_entry_requirements_page).to have_science_requirements

      %w[
        maths_requirements
        english_requirements
        science_requirements
      ].each do |subject|
        expect(new_entry_requirements_page.send(subject)).to have_field('1. Must have (least flexible)')
        expect(new_entry_requirements_page.send(subject)).to have_field('2: Taking')
        expect(new_entry_requirements_page.send(subject)).to have_field('3: Equivalence test')
      end
    end
  end

  context 'level secondary' do
    let(:level) { :secondary }
    scenario 'creating a new course' do
      visit "/organisations/#{provider.provider_code}/#{recruitment_cycle.year}" \
      "/courses/entry_requirements/new"

      expect(page.status_code).to eq(200)
      expect(new_entry_requirements_page).to(
        be_displayed(
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code
        )
      )

      expect(new_entry_requirements_page).to have_maths_requirements
      expect(new_entry_requirements_page).to have_english_requirements
      expect(new_entry_requirements_page).to_not have_science_requirements

      %w[
        maths_requirements
        english_requirements
      ].each do |subject|
        expect(new_entry_requirements_page.send(subject)).to have_field('1. Must have (least flexible)')
        expect(new_entry_requirements_page.send(subject)).to have_field('2: Taking')
        expect(new_entry_requirements_page.send(subject)).to have_field('3: Equivalence test')
      end
    end
  end
end
