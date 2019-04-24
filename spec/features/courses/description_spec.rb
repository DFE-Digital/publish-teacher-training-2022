require 'rails_helper'

feature 'Course description', type: :feature do
  let(:provider) { jsonapi(:provider, accredited_body?: false) }
  let(:course_jsonapi) {
    jsonapi(:course,
            funding: 'fee',
            site_statuses: [site_status],
            provider: provider,
            accrediting_provider: provider)
  }
  let(:site) { jsonapi(:site) }
  let(:site_status) do
    jsonapi(:site_status, :full_time_and_part_time, site: site)
  end
  let(:course)          { course_jsonapi.to_resource }
  let(:course_response) { course_jsonapi.render }
  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request(
      "/providers/A0/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
  end

  let(:course_page) { PageObjects::Page::Organisations::CourseDescription.new }

  describe 'with a fee paying course' do
    scenario 'it shows the course description page' do
      visit "/organisations/A0/courses/#{course.course_code}/description"

      expect(course_page.caption).to have_content(
        course.description
      )
      expect(course_page.title).to have_content(
        "#{course.name} (#{course.course_code})"
      )
      expect(course_page.about).to have_content(
        course.about_course
      )
      expect(course_page.interview_process).to have_content(
        course.interview_process
      )
      expect(course_page.placements_info).to have_content(
        course.how_school_placements_work
      )
      expect(course_page.length).to have_content(
        course.course_length
      )
      expect(course_page.uk_fees).to have_content(
        course.fee_uk_eu
      )
      expect(course_page.international_fees).to have_content(
        course.fee_international
      )
      expect(course_page.fee_details).to have_content(
        course.fee_details
      )
      expect(course_page.required_qualifications).to have_content(
        course.required_qualifications
      )
      expect(course_page.personal_qualities).to have_content(
        course.personal_qualities
      )
      expect(course_page.other_requirements).to have_content(
        course.other_requirements
      )
    end
  end

  describe 'with a salaried course' do
    let(:course_jsonapi) {
      jsonapi(:course,
              funding: 'salary',
              site_statuses: [site_status],
              provider: provider,
              accrediting_provider: provider)
    }
    let(:course)          { course_jsonapi.to_resource }
    let(:course_response) { course_jsonapi.render }

    scenario 'it shows the course description page' do
      visit "/organisations/A0/courses/#{course.course_code}/description"

      expect(course_page.caption).to have_content(
        course.description
      )
      expect(course_page.title).to have_content(
        "#{course.name} (#{course.course_code})"
      )
      expect(course_page.about).to have_content(
        course.about_course
      )
      expect(course_page.interview_process).to have_content(
        course.interview_process
      )
      expect(course_page.placements_info).to have_content(
        course.how_school_placements_work
      )
      expect(course_page.length).to have_content(
        course.course_length
      )
      expect(course_page.salary).to have_content(
        course.salary_details
      )
      expect(course_page.required_qualifications).to have_content(
        course.required_qualifications
      )
      expect(course_page.personal_qualities).to have_content(
        course.personal_qualities
      )
      expect(course_page.other_requirements).to have_content(
        course.other_requirements
      )
    end
  end
end
