require 'rails_helper'

feature 'Edit course SEND', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:send_page) { PageObjects::Page::Organisations::Send.new }
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
    send_page.load_with_course(course)
  end

  context 'a course with a send value of true' do
    let(:course) do
      build(
        :course,
        is_send: '1',
        edit_options: {
          is_send_options: %w[0 1]
        },
        provider: provider
      )
    end

    scenario 'can cancel changes' do
      click_on 'Cancel changes'
      expect(course_details_page).to be_displayed
    end

    scenario 'can navigate to the edit screen and back again' do
      course_details_page.load_with_course(course)
      click_on 'Change SEND'
      expect(send_page).to be_displayed
      click_on 'Back'
      expect(course_details_page).to be_displayed
    end

    scenario 'has the correct value selected' do
      expect(send_page.send_field.value).to eq('1')
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
