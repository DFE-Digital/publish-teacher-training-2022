require 'rails_helper'

feature 'Course fees', type: :feature do
  let(:course_jsonapi) do
    jsonapi(
      :course,
      provider: jsonapi(:provider, provider_code: 'A0'),
      course_length: 'OneYear'
    )
  end
  let(:course)          { course_jsonapi.to_resource }
  let(:course_response) { course_jsonapi.render }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
  end

  let(:course_fees_page) { PageObjects::Page::Organisations::CourseFees.new }

  scenario 'viewing the courses fees page' do
    visit fees_provider_course_path('AO', course.course_code)

    expect(course_fees_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_fees_page.title).to have_content(
      "Course length and fees"
    )
    expect(course_fees_page.course_length_one_year).to be_checked
    expect(course_fees_page.course_length_two_years).to_not be_checked
    expect(course_fees_page.course_fees_uk).to have_content(
      course.fee_uk_eu
    )
    expect(course_fees_page.course_fees_international).to have_content(
      course.fee_international
    )
    expect(course_fees_page.fee_details).to have_content(
      course.fee_details
    )
    expect(course_fees_page.financial_support).to have_content(
      course.financial_support
    )
  end
end
