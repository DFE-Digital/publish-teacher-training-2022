require 'rails_helper'

feature 'Course salary', type: :feature do
  let(:course_1) do
    jsonapi(
      :course,
      name: 'English',
      provider: provider,
      include_nulls: [:accrediting_provider],
      course_length: 'OneYear'
    )
  end
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

  let(:course_salary_page) { PageObjects::Page::Organisations::CourseSalary.new }

  scenario 'viewing the courses salary page' do
    visit salary_provider_course_path('AO', course.course_code)

    expect(course_salary_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_salary_page.title).to have_content(
      "Course length and salary"
    )
    expect(course_salary_page.course_length_one_year).to be_checked
    expect(course_salary_page.course_length_two_years).to_not be_checked
    expect(course_salary_page.course_salary_details).to have_content(
      course.salary_details
    )
  end
end
