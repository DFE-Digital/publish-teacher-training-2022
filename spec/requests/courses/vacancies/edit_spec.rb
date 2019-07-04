require 'rails_helper'

describe 'Edit vacancies' do
  describe 'viewing the edit vacancies page' do
    let(:course_json_api) do
      jsonapi(
        :course,
        :with_full_time_or_part_time_vacancy,
        site_statuses: [site_status, site_status_2]
      )
    end
    let(:course) { course_json_api.to_resource }
    let(:course_response) { course_json_api.render }
    let(:site) { jsonapi(:site) }
    let(:site_status) { jsonapi(:site_status, :full_time_and_part_time, site: site) }
    let(:site_status_2) { jsonapi(:site_status, :full_time_and_part_time, site: site) }

    let(:edit_vacancies_path) do
      "/organisations/A0/#{course.recruitment_cycle_year}/courses/#{course.course_code}/vacancies"
    end

    before do
      stub_omniauth
      stub_api_v2_request(
        "/providers/A0/courses/#{course.course_code}?include=site_statuses.site",
        course_response
      )
      get(auth_dfe_callback_path)
      get(edit_vacancies_path)
    end

    it 'has the correct heading' do
      expect(response.body).to include('Edit vacancies')
    end

    describe 'rendering vacancies checkboxes for a course with multiple running sites' do
      context 'with a full time and part time course' do
        let(:course_json_api) do
          jsonapi(
            :course,
            :with_full_time_or_part_time_vacancy,
            site_statuses: [site_status, site_status_2]
          )
        end

        it 'shows full time and part time checkboxes' do
          expect(response.body).to include(
            "#{site.location_name} (Full time)"
          )
          expect(response.body).to include(
            "#{site.location_name} (Part time)"
          )
        end
      end

      context 'with a full time course' do
        let(:course_json_api) do
          jsonapi(
            :course,
            :with_full_time_vacancy,
            site_statuses: [site_status, site_status_2]
          )
        end

        it 'shows a checkbox without a study mode' do
          expect(response.body).to include(
            site.location_name
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Full time)"
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Part time)"
          )
        end
      end

      context 'with a part time course' do
        let(:course_json_api) do
          jsonapi(
            :course,
            :with_part_time_vacancy,
            site_statuses: [site_status, site_status_2]
          )
        end

        it 'shows a checkbox without a study mode' do
          expect(response.body).to include(
            site.location_name
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Full time)"
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Part time)"
          )
        end
      end
    end
  end
end
