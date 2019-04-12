require 'rails_helper'

feature 'Show course', type: :feature do
  let(:course) {
    jsonapi :course,
      qualifications: %w[qts pgce],
      study_mode: 'full_time',
      start_date: Time.new(2019)
  }
  let(:course_response) { course.render }
  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request(
      "/providers/A0?include=courses.accrediting_provider",
      jsonapi(:provider).render
    )
    stub_api_v2_request(
      "/providers/A0/courses/#{course.attributes[:course_code]}",
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
  end
end
