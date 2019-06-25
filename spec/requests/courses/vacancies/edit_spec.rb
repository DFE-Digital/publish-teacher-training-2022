require 'rails_helper'

describe 'Edit vacancies' do
  describe 'viewing the edit vacancies page' do
    let(:course) do
      jsonapi(
        :course,
        :with_full_time_or_part_time_vacancy,
        site_statuses: [site_status, site_status_2]
      ).render
    end
    let(:course_code) { course[:data][:attributes][:course_code] }
    let(:site) { jsonapi(:site) }
    let(:site_status) { jsonapi(:site_status, :full_time_and_part_time, site: site) }
    let(:site_status_2) { jsonapi(:site_status, :full_time_and_part_time, site: site) }

    let(:edit_vacancies_path) do
      "/organisations/AO/courses/#{course_code}/vacancies"
    end

    before do
      stub_omniauth
      stub_api_v2_request(
        "/providers/AO/courses/#{course_code}?include=site_statuses.site",
        course
      )
      get(auth_dfe_callback_path)
      get(edit_vacancies_path)
    end

    it 'has the correct heading' do
      expect(response.body).to include('Edit vacancies')
    end

    describe 'rendering vacancies checkboxes for a course with multiple running sites' do
      context 'with a full time and part time course' do
        let(:course) do
          jsonapi(
            :course,
            :with_full_time_or_part_time_vacancy,
            site_statuses: [site_status, site_status_2]
          ).render
        end

        it 'shows full time and part time checkboxes' do
          expect(response.body).to include(
            "#{site.attributes[:location_name]} (Full time)"
          )
          expect(response.body).to include(
            "#{site.attributes[:location_name]} (Part time)"
          )
        end
      end

      context 'with a full time course' do
        let(:course) do
          jsonapi(
            :course,
            :with_full_time_vacancy,
            site_statuses: [site_status, site_status_2]
          ).render
        end

        it 'shows a checkbox without a study mode' do
          expect(response.body).to include(
            site.attributes[:location_name]
          )
          expect(response.body).not_to include(
            "#{site.attributes[:location_name]} (Full time)"
          )
          expect(response.body).not_to include(
            "#{site.attributes[:location_name]} (Part time)"
          )
        end
      end

      context 'with a part time course' do
        let(:course) do
          jsonapi(
            :course,
            :with_part_time_vacancy,
            site_statuses: [site_status, site_status_2]
          ).render
        end

        it 'shows a checkbox without a study mode' do
          expect(response.body).to include(
            site.attributes[:location_name]
          )
          expect(response.body).not_to include(
            "#{site.attributes[:location_name]} (Full time)"
          )
          expect(response.body).not_to include(
            "#{site.attributes[:location_name]} (Part time)"
          )
        end
      end
    end
  end
end
