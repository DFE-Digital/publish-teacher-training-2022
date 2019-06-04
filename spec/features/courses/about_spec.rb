require 'rails_helper'

feature 'About course', type: :feature do
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
      "/providers/AO/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course_response
    )
    stub_api_v2_request(
      "/providers/AO?include=courses.accrediting_provider",
      provider_response
    )
  end

  let(:about_course_page) { PageObjects::Page::Organisations::CourseAbout.new }

  scenario 'viewing the about courses page' do
    visit about_provider_course_path('AO', course.course_code)

    expect(about_course_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(about_course_page.title).to have_content(
      "About this course"
    )
    expect(about_course_page.about_textarea).to have_content(
      course.about_course
    )
    expect(about_course_page.interview_process_textarea).to have_content(
      course.interview_process
    )
    expect(about_course_page.how_school_placements_work_textarea).to have_content(
      course.how_school_placements_work
    )
  end
end
