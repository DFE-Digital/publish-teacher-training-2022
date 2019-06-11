require 'rails_helper'

feature 'Course requirements', type: :feature do
  let(:provider) do
    jsonapi(:provider, provider_code: 'AO')
  end

  let(:course) do
    jsonapi(
      :course,
      name: 'English',
      provider: provider,
      required_qualifications: 'Required qualifications',
      personal_qualities: 'Personal qualities',
      other_requirements: 'Other requirements'
    )
  end

  before do
    stub_omniauth
    stub_course_request(provider, course)
    stub_api_v2_request("/providers/AO?include=courses.accrediting_provider", provider.render)
    stub_api_v2_request("/providers/AO/courses/#{course.course_code}", course.render, :patch)
  end

  let(:course_requirements_page) { PageObjects::Page::Organisations::CourseRequirements.new }

  scenario 'viewing the courses requirements page' do
    visit description_provider_course_path(provider.provider_code, course.course_code)
    click_on 'Requirements and eligibility'

    expect(current_path).to eq requirements_provider_course_path('AO', course.course_code)

    expect(course_requirements_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_requirements_page.title).to have_content(
      "Requirements and eligibility"
    )
    expect(course_requirements_page.required_qualifications.value).to eq(
      course.required_qualifications
    )
    expect(course_requirements_page.personal_qualities.value).to eq(
      course.personal_qualities
    )
    expect(course_requirements_page.other_requirements.value).to eq(
      course.other_requirements
    )

    fill_in 'Qualifications needed', with: 'Something about the qualifications required for this course'
    fill_in 'Personal qualities (optional)', with: 'Something about the personal qualities required for this course'
    fill_in 'Other requirements (optional)', with: 'Something about the other requirements required for this course'

    click_on 'Save'

    expect(course_requirements_page.flash).to have_content(
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
