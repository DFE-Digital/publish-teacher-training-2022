require 'rails_helper'

feature 'Course requirements', type: :feature do
  let(:course_1) { jsonapi :course, name: 'English', provider: provider, include_nulls: [:accrediting_provider] }
  let(:course_2) { jsonapi :course, name: 'Biology', include_nulls: [:accrediting_provider] }
  let(:course_3) { jsonapi :course, name: 'Physics', include_nulls: [:accrediting_provider] }
  let(:course_4) { jsonapi :course, name: 'Science', include_nulls: [:accrediting_provider] }
  let(:courses)  { [course_2, course_3, course_4] }
  let(:provider) do
    jsonapi(:provider, courses: courses, accredited_body?: true, provider_code: 'AO')
  end
  let(:provider_response) { provider.render }
  let(:course)            { course_1.to_resource }
  let(:course_response)   { course_1.render }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
    stub_api_v2_request(
      "/providers/AO?include=courses.accrediting_provider",
      provider_response
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
