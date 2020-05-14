require "rails_helper"

describe "Edit vacancies" do
  describe "viewing the edit vacancies page" do
    let(:current_recruitment_cycle) { build(:recruitment_cycle) }
    let(:provider) { build(:provider, provider_code: "A0") }
    let(:course) do
      build(
        :course,
        :with_full_time_or_part_time_vacancy,
        provider: provider,
        site_statuses: [site_status, site_status_2],
      )
    end
    let(:course_response) { course.to_jsonapi(include: { site_statuses: :site }) }
    let(:site) { build(:site) }
    let(:site_status) { build(:site_status, :full_time_and_part_time, site: site) }
    let(:site_status_2) { build(:site_status, :full_time_and_part_time, site: site) }

    let(:edit_vacancies_path) do
      vacancies_provider_recruitment_cycle_course_path(
        course.provider.provider_code,
        course.recruitment_cycle.year,
        course.course_code,
      )
    end

    before do
      stub_omniauth
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}",
        current_recruitment_cycle.to_jsonapi,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{course.provider.provider_code}" \
        "/courses/#{course.course_code}" \
        "?include=site_statuses.site",
        course_response,
      )
      get(auth_dfe_callback_path)
      get(edit_vacancies_path)
    end

    context "Default recruitment cycle" do
      it "should redirect to new sites#index route" do
        get("/organisations/#{course.provider.provider_code}/courses/#{course.course_code}/vacancies")
        expect(response).to redirect_to(vacancies_provider_recruitment_cycle_course_path(
                                          course.provider.provider_code,
                                          current_recruitment_cycle.year,
                                          course.course_code,
                                        ))
      end
    end

    it "has the correct heading" do
      expect(response.body).to include("Edit vacancies")
    end

    describe "rendering vacancies checkboxes for a course with multiple running sites" do
      context "with a full time and part time course" do
        let(:course) do
          build(
            :course,
            :with_full_time_or_part_time_vacancy,
            provider: provider,
            site_statuses: [site_status, site_status_2],
          )
        end

        it "shows full time and part time checkboxes" do
          expect(response.body).to include(
            "#{site.location_name} (Full time)",
          )
          expect(response.body).to include(
            "#{site.location_name} (Part time)",
          )
        end
      end

      context "with a full time course" do
        let(:course) do
          build(
            :course,
            :with_full_time_vacancy,
            provider: provider,
            site_statuses: [site_status, site_status_2],
          )
        end

        it "shows a checkbox without a study mode" do
          expect(response.body).to include(
            site.location_name,
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Full time)",
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Part time)",
          )
        end
      end

      context "with a part time course" do
        let(:course) do
          build(
            :course,
            :with_part_time_vacancy,
            provider: provider,
            site_statuses: [site_status, site_status_2],
          )
        end

        it "shows a checkbox without a study mode" do
          expect(response.body).to include(
            site.location_name,
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Full time)",
          )
          expect(response.body).not_to include(
            "#{site.location_name} (Part time)",
          )
        end
      end
    end
  end
end
