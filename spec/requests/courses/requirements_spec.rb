require "rails_helper"

describe "Courses", type: :request do
  describe "GET requirements" do
    let(:current_recruitment_cycle) { build(:recruitment_cycle) }
    let(:course) do
      build :course,
            name: "English",
            course_code: "EN01",
            provider: provider,
            include_nulls: [:accrediting_provider],
            recruitment_cycle: current_recruitment_cycle
    end
    let(:provider) { build(:provider, accredited_body?: true, provider_code: "A0") }
    let(:course_response) { course.to_jsonapi(include: %i[subjects sites provider accrediting_provider]) }

    let(:course_1) { build :course, provider: provider, name: "English", course_code: "EN01", include_nulls: [:accrediting_provider] }
    let(:course_2) do
      build :course,
            name: "Biology",
            provider: provider,
            include_nulls: [:accrediting_provider],
            required_qualifications: "Foo",
            personal_qualities: "Foobar",
            other_requirements: "Foobarbar"
    end
    let(:courses) { [course_1, course_2] }
    let(:provider_2) { build(:provider, courses: courses, accredited_body?: true, provider_code: "A0") }
    let(:provider_2_response) { provider_2.to_jsonapi(include: %i[courses accrediting_provider]) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_resource(current_recruitment_cycle)
      stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_2, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(provider_2, include: "courses.accrediting_provider")
      stub_api_v2_resource(provider)
    end

    context "Default recruitment cycle" do
      it "should redirect to new courses#requirements route" do
        get("/organisations/#{provider.provider_code}/courses/#{course.course_code}/requirements")
        expect(response).to redirect_to(requirements_provider_recruitment_cycle_course_path(provider.provider_code, Settings.current_cycle, course.course_code))
      end
    end

    it "renders the course requirements" do
      get(requirements_provider_recruitment_cycle_course_path(
            provider.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
          ))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})",
      )
      expect(response.body).to include(
        "Requirements and eligibility",
      )
      expect(response.body).to_not include(
        "Your changes are not yet saved",
      )
    end

    context "with copy_from parameter" do
      it "renders the course requirements with data from chosen" do
        get(requirements_provider_recruitment_cycle_course_path(
              provider.provider_code,
              course.recruitment_cycle_year,
              course.course_code,
              params: { copy_from: course_2.course_code },
            ))

        expect(response.body).to include(
          "Your changes are not yet saved",
        )
        expect(response.body).to include(
          course_2.required_qualifications,
        )
        expect(response.body).to include(
          course_2.personal_qualities,
        )
        expect(response.body).to include(
          course_2.other_requirements,
        )
      end
    end
  end
end
