require "rails_helper"

describe "Courses", type: :request do
  describe "DELETE" do
    let(:current_recruitment_cycle) { build :recruitment_cycle }
    let(:course) do
      build :course,
            name: "English",
            course_code: "EN01",
            provider: provider,
            include_nulls: [:accrediting_provider],
            recruitment_cycle: current_recruitment_cycle
    end
    let(:provider) { build :provider, accredited_body?: true, provider_code: "A0" }
    let(:course_response) { course.to_jsonapi(include: %i[subjects sites provider accrediting_provider recruitment_cycle]) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
      stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}?include=subjects,sites,provider.sites,accrediting_provider",
        course_response,
      )
    end

    it "renders the course delete" do
      get(delete_provider_recruitment_cycle_course_path(provider.provider_code,
                                                        course.recruitment_cycle.year,
                                                        course.course_code))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})",
      )
      expect(response.body).to include(
        "Are you sure you want to delete this course?",
      )
    end
  end
end
