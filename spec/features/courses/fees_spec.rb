require 'rails_helper'

feature 'Course fees', type: :feature do
  let(:course_1) do
    jsonapi(
      :course,
      :with_fees,
      provider: provider,
      include_nulls: [:accrediting_provider]
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
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}",
      course_response,
      :patch
    )
  end

  let(:course_fees_page) { PageObjects::Page::Organisations::CourseFees.new }

  scenario 'viewing the courses fees page' do
    visit description_provider_course_path(provider.provider_code, course.course_code)

    click_on 'Course length and fees'

    expect(current_path).to eq fees_provider_course_path('AO', course.course_code)

    expect(course_fees_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_fees_page.title).to have_content(
      "Course length and fees"
    )
    expect(course_fees_page.course_length_one_year).not_to be_checked
    expect(course_fees_page.course_length_two_years).to be_checked
    expect(course_fees_page.course_fees_uk_eu.value).to have_content(
      course.fee_uk_eu
    )
    expect(course_fees_page.course_fees_international.value).to have_content(
      course.fee_international
    )
    expect(course_fees_page.fee_details).to have_content(
      course.fee_details
    )
    expect(course_fees_page.financial_support).to have_content(
      course.financial_support
    )

    choose '1 year'
    fill_in 'Fee for UK and EU students', with: '8000'
    fill_in 'Fee for international students (optional)', with: '16000'
    fill_in 'Fee details (optional)', with: 'Test fee details'
    fill_in(
      'Financial support you offer (optional)',
      with: 'Test financial support'
    )

    click_on 'Save'

    expect(course_fees_page.flash).to have_content(
      'Your changes have been saved'
    )
    expect(current_path).to eq description_provider_course_path('AO', course.course_code)
  end
end
