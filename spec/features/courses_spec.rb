require 'rails_helper'

RSpec.feature 'Edit course vacancies', type: :feature do
  scenario 'Navigate to /organisations/AO/courses/X100/vacancies' do
    course            = build(:course, course_code: 'X100')
    course_attributes = course['attributes']
    stub_omniauth
    stub_session_create
    stub_api_v2_request('/providers/AO/courses/X100', build(:courses_response, data: course))

    visit("/organisations/AO/courses/#{course_attributes[:course_code]}/vacancies")
    expect(page).to have_link('Back', href: "#{Settings.manage_ui.base_url}/organisation/AO/courses/#{course_attributes[:course_code]}")
    expect(find('h1')).to have_content('Edit vacancies')
    expect(find('.govuk-caption-xl')).to have_content("#{course_attributes[:name]} (#{course_attributes[:course_code]})")
  end
end
