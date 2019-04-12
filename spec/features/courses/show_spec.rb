require 'rails_helper'

feature 'Show course', type: :feature do
  let(:course) {
    jsonapi :course,
      qualifications: %w[qts pgce],
      study_mode: 'full_time',
      start_date: Time.new(2019),
      site_statuses: [site_status],
      provider: jsonapi(:provider)
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
      "/providers/A0/courses/#{course.attributes[:course_code]}?include=site_statuses.site,provider.sites",
      course_response
    )
  end

  scenario 'viewing the show courses page' do
    visit "/organisations/A0/courses/#{course.attributes[:course_code]}"

    expect(find('.govuk-caption-xl')).to have_content(
      course.attributes[:description]
    )
    expect(find('.govuk-heading-xl')).to have_content(
      "#{course.attributes[:name]} (#{course.attributes[:course_code]})"
    )
    expect(find('[data-qa=course__qualifications]')).to have_content(
      'PGCE with QTS'
    )
    expect(find('[data-qa=course__study_mode]')).to have_content(
      'Full time'
    )
    expect(find('[data-qa=course__start_date]')).to have_content(
      'January 2019'
    )
    expect(find('[data-qa=course__name]')).to have_content(
      course.attributes[:name]
    )
    expect(find('[data-qa=course__description]')).to have_content(
      course.attributes[:description]
    )
    expect(find('[data-qa=course__course_code]')).to have_content(
      course.attributes[:course_code]
    )
    expect(find('[data-qa=course__locations]')).to have_content(
      site.attributes[:location_name]
    )
  end
end
