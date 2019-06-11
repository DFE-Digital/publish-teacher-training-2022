require 'rails_helper'

feature 'Course requirements', type: :feature do
  let(:course_1) { jsonapi :course, name: 'English', provider: provider, include_nulls: [:accrediting_provider] }
  let(:course_2) { jsonapi :course, name: 'Biology', include_nulls: [:accrediting_provider] }
  let(:provider) do
    jsonapi(:provider, courses: [course_2], accredited_body?: true, provider_code: 'AO')
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
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}",
      course_response,
      :patch
    )
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
    expect(course_requirements_page.required_qualifications).to have_content(
      course.required_qualifications
    )
    expect(course_requirements_page.personal_qualities).to have_content(
      course.personal_qualities
    )
    expect(course_requirements_page.other_requirements).to have_content(
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
end
