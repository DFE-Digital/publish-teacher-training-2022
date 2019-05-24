require 'rails_helper'

feature 'Preview course', type: :feature do
  let(:course_jsonapi) do
    jsonapi(:course,
            name: 'English',
            provider: provider,
            course_length: 'OneYear',
            applications_open_from: '2019-01-01T00:00:00Z',
            start_date: '2019-09-01T00:00:00Z',
            fee_uk_eu: '9250.0',
            fee_international: '9250.0')
  end
  let(:provider)         { jsonapi(:provider, provider_code: 'AO', website: 'https://scitt.org') }
  let(:course)           { course_jsonapi.to_resource }
  let(:course_response)  { course_jsonapi.render }
  let(:decorated_course) { course.decorate }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
  end

  let(:preview_course_page) { PageObjects::Page::Organisations::CoursePreview.new }

  scenario 'viewing the show courses page' do
    visit preview_provider_course_path('AO', course.course_code)

    expect(preview_course_page.title).to have_content(
      "#{course.name} (#{course.course_code})"
    )

    expect(preview_course_page.sub_title).to have_content(
      provider.provider_name
    )

    expect(preview_course_page.description).to have_content(
      course.description
    )

    expect(preview_course_page.qualifications).to have_content(
      'PGCE with QTS'
    )

    expect(preview_course_page.length).to have_content(
      decorated_course.length
    )

    expect(preview_course_page.applications_open_from).to have_content(
      '1 January 2019'
    )

    expect(preview_course_page.start_date).to have_content(
      'September 2019'
    )

    expect(preview_course_page.provider_website).to have_content(
      provider.website
    )

    expect(preview_course_page.vacancies).to have_content(
      'No'
    )

    expect(preview_course_page.about_course).to have_content(
      course.about_course
    )

    expect(preview_course_page.interview_process).to have_content(
      course.interview_process
    )

    expect(preview_course_page.school_placements).to have_content(
      course.how_school_placements_work
    )

    expect(preview_course_page.uk_fees).to have_content(
      decorated_course.uk_fees
    )

    expect(preview_course_page.eu_fees).to have_content(
      decorated_course.eu_fees
    )

    expect(preview_course_page.international_fees).to have_content(
      decorated_course.international_fees
    )

    expect(preview_course_page).to_not have_salary_details
  end
end
