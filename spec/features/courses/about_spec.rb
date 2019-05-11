require 'rails_helper'

feature 'About course', type: :feature do
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
