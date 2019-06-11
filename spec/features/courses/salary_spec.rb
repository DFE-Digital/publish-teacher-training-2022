require 'rails_helper'

feature 'Course salary', type: :feature do
  let(:provider) do
    jsonapi(:provider, provider_code: 'AO')
  end

  let(:course) do
    jsonapi(
      :course,
      name: 'English',
      provider: provider,
      course_length: 'OneYear',
      salary_details: 'Salary details',
      funding: 'salary'
    )
  end

  before do
    stub_omniauth
    stub_course_request(provider, course)
    stub_api_v2_request("/providers/AO?include=courses.accrediting_provider", provider.render)
    stub_api_v2_request("/providers/AO/courses/#{course.course_code}", course.render, :patch)
  end

  let(:course_salary_page) { PageObjects::Page::Organisations::CourseSalary.new }

  scenario 'viewing the courses salary page' do
    visit description_provider_course_path(provider.provider_code, course.course_code)

    click_on 'Course length and salary'

    expect(current_path).to eq salary_provider_course_path('AO', course.course_code)

    expect(course_salary_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_salary_page.title).to have_content(
      "Course length and salary"
    )
    expect(course_salary_page.course_length_one_year).to be_checked
    expect(course_salary_page.course_length_two_years).to_not be_checked
    expect(course_salary_page.course_salary_details.value).to eq(
      course.salary_details
    )

    choose '2 years'
    fill_in 'Salary', with: 'Test salary details'
    click_on 'Save'

    expect(course_salary_page.flash).to have_content(
      'Your changes have been saved'
    )

    expect(current_path).to eq description_provider_course_path('AO', course.course_code)
  end

  def stub_course_request(provider, course)
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course.render
    )
  end
end
