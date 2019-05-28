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
            fee_international: '9250.0',
            has_scholarship_and_bursary?: true,
            scholarship_amount: '20000',
            bursary_amount: '22000',
            personal_qualities: 'We are looking for ambitious trainee teachers who are passionate and enthusiastic about their subject and have a desire to share that with young people of all abilities in this particular age range.',
            other_requirements: 'You will need three years of prior work experience, but not necessarily in an educational context.')
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
      '£9,250'
    )

    expect(preview_course_page.eu_fees).to have_content(
      '£9,250'
    )

    expect(preview_course_page.international_fees).to have_content(
      '£9,250'
    )

    expect(preview_course_page).to_not have_salary_details

    expect(preview_course_page.scholarship_amount).to have_content(
      '£20,000'
    )

    expect(preview_course_page.bursary_amount).to have_content(
      '£22,000'
    )

    expect(preview_course_page.required_qualifications).to have_content(
      course.required_qualifications
    )

    expect(preview_course_page.personal_qualities).to have_content(
      course.personal_qualities
    )

    expect(preview_course_page.other_requirements).to have_content(
      course.other_requirements
    )

    expect(preview_course_page.train_with_us).to have_content(
      provider.train_with_us
    )

    expect(preview_course_page.train_with_disability).to have_content(
      provider.train_with_disability
    )
  end
end
