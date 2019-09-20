require 'rails_helper'

feature 'Edit course apprenticeship status', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:apprenticeship_page) { PageObjects::Page::Organisations::CourseApprenticeship.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider, accredited_body?: true) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
      provider.to_jsonapi(include: %i[courses accrediting_provider])
    )

    stub_course_request
    stub_course_details_tab
    apprenticeship_page.load_with_course(course)
  end

  context 'A course that can be an apprenticeship' do
    let(:funding_type) { 'apprenticeship' }
    let(:course) do
      build(
        :course,
        funding_type: funding_type,
        provider: provider
      )
    end

    scenario 'can cancel changes' do
      click_on 'Cancel changes'
      expect(course_details_page).to be_displayed
    end

    scenario 'can navigate to the edit screen and back again' do
      course_details_page.load_with_course(course)
      click_on 'Change apprenticeship'
      expect(apprenticeship_page).to be_displayed
      click_on 'Back'
      expect(course_details_page).to be_displayed
    end

    scenario 'presents the correct choices' do
      expect(apprenticeship_page).to have_funding_type_fields
      expect(apprenticeship_page.funding_type_fields)
        .to have_selector('[for="course_funding_type_apprenticeship"]', text: 'Yes')
      expect(apprenticeship_page.funding_type_fields)
        .to have_selector('[for="course_funding_type_fee"]', text: 'No')
    end

    scenario 'clicking no sets funding type to fee' do
      patch_stub = stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}/courses" \
        "/#{course.course_code}",
        {},
        :patch,
        body: {
          data: {
            course_code: course.course_code,
            type: 'courses',
            attributes: {
              funding_type: 'fee'
            }
          }
        }.to_json
      )

      apprenticeship_page.funding_type_fee.click
      apprenticeship_page.save.click

      expect(patch_stub).to have_been_requested
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
