require 'rails_helper'

feature 'Show course', type: :feature do
  let(:provider) { jsonapi(:provider, accredited_body?: false) }
  let(:course) {
    jsonapi :course,
      qualifications: %w[qts pgce],
      study_mode: 'full_time',
      start_date: Time.new(2019),
      site_statuses: [site_status],
      provider: provider,
      accrediting_provider: provider
  }
  let(:site) { jsonapi(:site) }
  let(:site_status) do
    jsonapi(:site_status, :full_time_and_part_time, site: site)
  end
  let(:course_response) { course.render }
  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request(
      "/providers/A0/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
  end

  let(:course_page) { PageObjects::Page::Organisations::Course.new }

  scenario 'viewing the show courses page' do
    visit "/organisations/A0/courses/#{course.course_code}"

    expect(course_page.caption).to have_content(
      course.description
    )
    expect(course_page.title).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_page.subjects).to have_content(
      course.subjects.sort.join(' ').to_s
    )
    expect(course_page.qualifications).to have_content(
      'PGCE with QTS'
    )
    expect(course_page.study_mode).to have_content(
      'Full time'
    )
    expect(course_page.start_date).to have_content(
      'January 2019'
    )
    expect(course_page.name).to have_content(
      course.name
    )
    expect(course_page.description).to have_content(
      course.description
    )
    expect(course_page.course_code).to have_content(
      course.course_code
    )
    expect(course_page.locations).to have_content(
      site.location_name
    )
    expect { course_page.apprenticeship }.to raise_error(Capybara::ElementNotFound)
    expect(course_page.funding).to have_content(
      'Fee paying (no salary)'
    )
    expect(course_page.accredited_body).to have_content(
      provider.provider_name
    )
    expect(course_page.applications_open).to have_content(
      '1 January 2019'
    )
    expect(course_page.is_send).to have_content(
      'No'
    )
    expect(course_page.level).to have_content(
      'Secondary'
    )
  end
end
