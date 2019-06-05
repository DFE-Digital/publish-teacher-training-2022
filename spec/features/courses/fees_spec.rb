require 'rails_helper'

feature 'Course fees', type: :feature do
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
