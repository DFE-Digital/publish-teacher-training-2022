require "rails_helper"

describe "Courses", type: :request do
  describe "GET salary" do
    let(:current_recruitment_cycle) { build :recruitment_cycle }
    let(:course) do
      build :course,
            name: "English",
            course_code: "EN01",
            provider: provider,
            include_nulls: [:accrediting_provider],
            recruitment_cycle: current_recruitment_cycle
    end
    let(:provider)          { build(:provider, accredited_body?: true, provider_code: "A0") }
    let(:course_response)   { course.to_jsonapi(include: %i[sites provider accrediting_provider recruitment_cycle]) }

    let(:course_1) { build :course, name: "English", course_code: "EN01", include_nulls: [:accrediting_provider] }
    let(:course_2) do
      build :course,
            name: "Biology",
            include_nulls: [:accrediting_provider],
            course_length: "TwoYears",
            salary_details: "Some information about the salary"
    end
    let(:courses) { [course_1, course_2] }
    let(:provider_2) { build :provider, courses: courses, accredited_body?: true, provider_code: "A0" }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course_response,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course_2.course_code}?include=sites,provider.sites,accrediting_provider",
        course_2.to_jsonapi,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}?include=courses.accrediting_provider",
        provider_2.to_jsonapi(include: %i[courses accredited_body]),
      )
    end

    context "Default recruitment cycle" do
      it "should redirect to new courses#salary route" do
        get("/organisations/#{provider.provider_code}/courses/#{course.course_code}/salary")
        expect(response).to redirect_to(salary_provider_recruitment_cycle_course_path(provider.provider_code, "2019", course.course_code))
      end
    end

    it "renders the course length and fees" do
      get(salary_provider_recruitment_cycle_course_path(provider.provider_code,
                                                        course.recruitment_cycle_year,
                                                        course.course_code))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})",
      )
      expect(response.body).to include(
        "Course length and salary",
      )
      expect(response.body).to_not include(
        "Your changes are not yet saved",
      )
    end

    context "with copy_from parameter" do
      it "renders the course length and fees with data from chosen" do
        get(salary_provider_recruitment_cycle_course_path(provider.provider_code,
                                                          course.recruitment_cycle_year,
                                                          course.course_code,
                                                          params: { copy_from: course_2.course_code }))

        expect(response.body).to include(
          "Your changes are not yet saved",
        )
        expect(response.body).to include(
          course_2.course_length,
        )
        expect(response.body).to include(
          course_2.salary_details,
        )
      end
    end
  end
end
