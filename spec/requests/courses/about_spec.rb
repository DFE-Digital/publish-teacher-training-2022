require "rails_helper"

describe "Courses", type: :request do
  describe "GET about" do
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
    let(:course_response) { course.to_jsonapi(include: %i[sites provider accrediting_provider recruitment_cycle]) }

    let(:course_1) { build :course, name: "English", course_code: "EN01", include_nulls: [:accrediting_provider] }
    let(:course_2) do
      build :course,
            name: "Biology",
            include_nulls: [:accrediting_provider],
            about_course: "Foo",
            interview_process: "Foobar",
            how_school_placements_work: "Foobarbar"
    end
    let(:course_2_response)   { course_2.to_jsonapi }
    let(:courses)             { [course_1, course_2] }
    let(:provider2)           { build(:provider, courses: courses, accredited_body?: true, provider_code: "A0") }
    let(:provider_2_response) { provider2.to_jsonapi(include: %i[courses accrediting_provider]) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
      stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course_response,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course_2.course_code}?include=sites,provider.sites,accrediting_provider",
        course_2_response,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}?include=courses.accrediting_provider",
        provider_2_response,
      )
    end

    context "Default recruitment cycle" do
      it "should redirect to new courses#index route" do
        get("/organisations/#{provider.provider_code}/courses/#{course.course_code}")
        expect(response).to redirect_to(provider_recruitment_cycle_course_path(provider.provider_code, Settings.current_cycle, course.course_code))
      end
    end

    it "renders the course about" do
      get(about_provider_recruitment_cycle_course_path(provider.provider_code,
                                                       course.recruitment_cycle.year,
                                                       course.course_code))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})",
      )
      expect(response.body).to include(
        "About this course",
      )
      expect(response.body).to_not include(
        "Your changes are not yet saved",
      )
    end

    context "with copy_from parameter" do
      it "renders the course about with data from chosen" do
        get(about_provider_recruitment_cycle_course_path(provider.provider_code,
                                                         course.recruitment_cycle.year,
                                                         course.course_code,
                                                         params: { copy_from: course_2.course_code }))

        expect(response.body).to include(
          "Your changes are not yet saved",
        )
        expect(response.body).to include(
          course_2.about_course,
        )
        expect(response.body).to include(
          course_2.interview_process,
        )
        expect(response.body).to include(
          course_2.how_school_placements_work,
        )
      end
    end
  end

  describe "UPDATE about" do
    let(:current_recruitment_cycle) { build :recruitment_cycle }
    let(:course)          { build :course, provider: provider }
    let(:provider)        { build :provider, provider_code: "A0" }
    let(:course_response) { course.to_jsonapi(include: %i[sites provider accrediting_provider recruitment_cycle]) }

    let(:course_params) do
      {
        page: "about",
        about_course: "Something about this course",
        how_school_placements_work: "Something about how school placements work",
        interview_process: "Something about the interview process",
      }
    end

    let(:request_params) do
      {
        "_jsonapi" => {
          data: {
            course_code: course.course_code,
            type: "courses",
            attributes: course_params,
          },
        },
        "course" => course_params,
      }
    end

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
      stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course_response,
      )
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}?include=courses.accrediting_provider",
        provider.to_jsonapi,
      )
    end

    context "without errors" do
      let(:current_recruitment_cycle) { build(:recruitment_cycle) }

      before do
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
        stub_api_v2_request(
          "/recruitment_cycles/#{course.recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}",
          {}, :patch, 200
        ).with(body: {
          data: {
            course_code: course.course_code,
            type: "courses",
            attributes: course_params,
          },
        }.to_json)

        patch about_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle.year, course.course_code), params: request_params
      end

      it "redirects to the course description page" do
        expect(flash[:success]).to include("Your changes have been saved")
        expect(response).to redirect_to(provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle.year, course.course_code))
      end
    end

    context "with errors" do
      before do
        stub_api_v2_request(
          "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}",
          build(:error, :for_course_publish), :patch, 422
        )

        patch about_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle.year, course.course_code), params: request_params
      end

      it "redirects to the course about page" do
        expect(response).to render_template :about
      end
    end
  end
end
