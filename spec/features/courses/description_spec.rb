require 'rails_helper'

feature 'Course description', type: :feature do
  let(:provider) { jsonapi(:provider, accredited_body?: false) }
  let(:course) {
    jsonapi :course,
      funding: 'fee',
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
      "/providers/A0/courses/#{course.attributes[:course_code]}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
  end

  let(:course_page) { PageObjects::Page::Organisations::CourseDescription.new }

  describe 'with a fee paying course' do
    scenario 'it shows the course description page' do
      visit "/organisations/A0/courses/#{course.attributes[:course_code]}/description"

      expect(course_page.caption).to have_content(
        course.attributes[:description]
      )
      expect(course_page.title).to have_content(
        "#{course.attributes[:name]} (#{course.attributes[:course_code]})"
      )
      expect(course_page.about).to have_content(
        course.attributes[:about_course]
      )
      expect(course_page.interview_process).to have_content(
        course.attributes[:interview_process]
      )
      expect(course_page.placements_info).to have_content(
        course.attributes[:how_school_placements_work]
      )
      expect(course_page.length).to have_content(
        course.attributes[:course_length]
      )
      expect(course_page.uk_fees).to have_content(
        course.attributes[:fee_uk_eu]
      )
      expect(course_page.international_fees).to have_content(
        course.attributes[:international_fees]
      )
      expect(course_page.fee_details).to have_content(
        site.attributes[:fee_details]
      )
      expect(course_page.required_qualifications).to have_content(
        site.attributes[:required_qualifications]
      )
      expect(course_page.personal_qualities).to have_content(
        site.attributes[:personal_qualities]
      )
      expect(course_page.other_requirements).to have_content(
        site.attributes[:other_requirements]
      )
    end
  end

  describe 'with a fee paying course' do
    let(:course) {
      jsonapi :course,
      funding: 'salary',
      site_statuses: [site_status],
      provider: provider,
      accrediting_provider: provider
    }

    scenario 'it shows the course description page' do
      visit "/organisations/A0/courses/#{course.attributes[:course_code]}/description"

      expect(course_page.caption).to have_content(
        course.attributes[:description]
      )
      expect(course_page.title).to have_content(
        "#{course.attributes[:name]} (#{course.attributes[:course_code]})"
      )
      expect(course_page.about).to have_content(
        course.attributes[:about_course]
      )
      expect(course_page.interview_process).to have_content(
        course.attributes[:interview_process]
      )
      expect(course_page.placements_info).to have_content(
        course.attributes[:how_school_placements_work]
      )
      expect(course_page.length).to have_content(
        course.attributes[:course_length]
      )
      expect(course_page.salary).to have_content(
        course.attributes[:salary_details]
      )
      expect(course_page.required_qualifications).to have_content(
        site.attributes[:required_qualifications]
      )
      expect(course_page.personal_qualities).to have_content(
        site.attributes[:personal_qualities]
      )
      expect(course_page.other_requirements).to have_content(
        site.attributes[:other_requirements]
      )
    end
  end
end
