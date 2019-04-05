require 'rails_helper'

feature 'Show course', type: :feature do
  let(:course) { jsonapi :course }
  let(:course_response) { course.render }
  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request(
      "/providers/A0/courses/#{course.attributes[:course_code]}",
      course_response
    )
  end

  scenario 'viewing the show courses page' do
    visit "/organisations/A0/courses/#{course.attributes[:course_code]}"

    expect(find('.govuk-caption-xl')).to have_content(course.attributes[:description])
    expect(find('.govuk-heading-xl')).to have_content(
      "#{course.attributes[:name]} (#{course.attributes[:course_code]})"
    )
  end
end
