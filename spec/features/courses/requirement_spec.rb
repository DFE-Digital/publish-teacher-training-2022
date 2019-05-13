require 'rails_helper'

feature 'Course requirements', type: :feature do
  let(:course_jsonapi) do
    jsonapi(
      :course,
      provider: jsonapi(:provider, provider_code: 'A0')
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

  let(:about_course_page) { PageObjects::Page::Organisations::CourseRequirements.new }

  scenario 'viewing the courses requirements page' do
    visit requirements_provider_course_path('AO', course.course_code)

    expect(about_course_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(about_course_page.title).to have_content(
      "Requirements and eligibility"
    )
    expect(about_course_page.required_qualifications).to have_content(
      course.required_qualifications
    )
    expect(about_course_page.personal_qualities).to have_content(
      course.personal_qualities
    )
    expect(about_course_page.other_requirements).to have_content(
      course.other_requirements
    )
  end
end
