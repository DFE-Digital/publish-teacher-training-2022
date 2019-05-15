require 'rails_helper'

feature 'Course description', type: :feature do
  let(:provider) { jsonapi(:provider, accredited_body?: false) }
  let(:course_jsonapi) {
    jsonapi(:course,
            has_vacancies?: true,
            open_for_applications?: true,
            funding: 'fee',
            site_statuses: [site_status],
            provider: provider,
            accrediting_provider: provider,
            last_published_at: '2019-03-05T14:42:34Z')
  }
  let(:site) { jsonapi(:site) }
  let(:site_status) do
    jsonapi(:site_status, :full_time_and_part_time, site: site)
  end
  let(:course)          { course_jsonapi.to_resource }
  let(:course_response) { course_jsonapi.render }
  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
    visit "/organisations/#{provider.provider_code}/courses/#{course.course_code}/description"
  end

  let(:course_page) { PageObjects::Page::Organisations::CourseDescription.new }

  describe 'with a fee paying course' do
    scenario 'it shows the course description page' do
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
      expect(course_page.last_published_at).to have_content(
        'Last published: 5 March 2019'
      )
      expect(course_page).to_not have_preview_link
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
      expect(course_page).to_not have_preview_link
    end
  end

  describe 'shows status panel' do
    scenario 'displays status panel' do
      expect(course_page.is_findable).to have_content('Yes')
      expect(course_page.has_vacancies).to have_content('Yes')
      expect(course_page.open_for_applications).to have_content('Open')
      expect(course_page.status_tag).to have_content('Published')
    end

    context 'unpublished course' do
      let(:course_jsonapi) {
        jsonapi(:course,
                findable?: false,
                content_status: 'draft',
                site_statuses: [site_status],
                provider: provider,
                accrediting_provider: provider)
      }
      let(:course)          { course_jsonapi.to_resource }
      let(:course_response) { course_jsonapi.render }

      scenario 'displays status panel' do
        expect(course_page.is_findable).to have_content('No')
        expect(course_page.status_tag).to have_content('Draft')
        expect(course_page).to have_preview_link
      end

      describe 'publishing' do
        before do
          stub_api_v2_request(
            "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
            course_response
          )
        end

        context 'without errors' do
          before do
            stub_api_v2_request(
              "/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
              nil,
              :post
            )
          end

          scenario 'it shows the description page with success flash' do
            course_page.publish.click

            expect(course_page).to be_displayed
            expect(course_page.success_summary).to have_content("Your course has been published\nThe link for this course is: https://localhost:5000/course/#{provider.provider_code}/#{course.course_code}")
          end
        end

        context 'with errors' do
          before do
            stub_api_v2_request(
              "/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
              build(:error, :for_course_publish),
              :post,
              422
            )
          end

          scenario 'it shows the description page with validation errors' do
            course_page.publish.click

            expect(course_page).to be_displayed
            expect(course_page.error_summary).to have_content("About course can't be blank")
          end
        end
      end
    end
  end
end
