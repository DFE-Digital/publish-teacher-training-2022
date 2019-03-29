require 'rails_helper'

feature 'Edit course vacancies', type: :feature do
  let(:course) do
    jsonapi(:course, :with_vacancy, site_statuses: [site_status]).render
  end
  let(:course_attributes) { course[:data][:attributes] }
  let(:site) { jsonapi(:site) }
  let(:site_status) { jsonapi(:site_status, :full_time_and_part_time, site: site) }

  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request "/providers/AO/courses/#{course_attributes[:course_code]}", course
  end

  scenario 'viewing the edit vacancies page' do
    visit "/organisations/AO/courses/#{course_attributes[:course_code]}/vacancies"

    expect(page).to have_link(
      'Back',
      href: "#{Settings.manage_ui.base_url}/organisation/AO/course/self/#{course_attributes[:course_code]}"
    )
    expect(find('h1')).to have_content('Edit vacancies')
    expect(find('.govuk-caption-xl')).to have_content("#{course_attributes[:name]} (#{course_attributes[:course_code]})")
  end

  context 'where the course is both full time or part time' do
    let(:course_without_full_time_vacancy) do
      jsonapi(:course,
              :with_vacancy,
              course_code:   course_attributes[:course_code],
              site_statuses: [part_time_site_status]).render
    end
    let(:part_time_site_status) do
      jsonapi(:site_status, :part_time, id: site_status.id, site: site)
    end

    before do
      stub_request :patch, "http://localhost:3001/api/v2/site_statuses/#{site_status.id}"
    end

    scenario 'remove the full time vacancy' do
      visit "/organisations/AO/courses/#{course_attributes[:course_code]}/vacancies"

      check("#{site.attributes[:location_name]} (Full time)", allow_label_click: true)
      stub_api_v2_request "/providers/AO/courses/#{course_attributes[:course_code]}", course_without_full_time_vacancy
      click_on 'Publish changes'

      expect(page.find('.govuk-success-summary')).to have_content 'Course vacancies published'
      expect(page).to have_field("#{site.attributes[:location_name]} (Full time)", checked: false)
    end
  end
end
