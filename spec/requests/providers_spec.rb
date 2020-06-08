require "rails_helper"

describe "Providers", type: :request do
  context "when the user is authenticated" do
    let(:provider) { build(:provider) }

    before do
      stub_omniauth(provider: provider)
      get(auth_dfe_callback_path)
    end

    describe "GET index" do
      let(:path) { root_path } # providers_path redirects to root, and the list is rendered from there
      context "with 1 provider" do
        it "redirects to providers show" do
          current_recruitment_cycle = build(:recruitment_cycle)
          stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
          stub_api_v2_request(
            "/recruitment_cycles/2020/providers?page[page]=1",
            resource_list_to_jsonapi([provider], meta: { count: 1 }),
          )
          get(path)
          expect(response).to redirect_to provider_path(provider.provider_code)
        end
      end

      context "with 2 or more providers" do
        it "renders providers index" do
          current_recruitment_cycle = build(:recruitment_cycle)
          provider1 = build(:provider, include_counts: [:courses])
          provider2 = build(:provider, include_counts: [:courses])
          providers = [provider1, provider2]
          stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
          stub_api_v2_request(
            "/recruitment_cycles/2020/providers?page[page]=1",
            resource_list_to_jsonapi(providers, meta: { count: 2 }),
          )
          get(path)
          expect(response.body).to include("Organisations")
          expect(response.body).to include(provider1.provider_name)
        end
      end

      context "user has no providers" do
        it "shows no-providers page" do
          current_recruitment_cycle = build(:recruitment_cycle)
          stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
          stub_api_v2_request(
            "/recruitment_cycles/2020/providers?page[page]=1",
            resource_list_to_jsonapi([], meta: { count: 0 }),
          )
          get(path)
          expect(response).to have_http_status(:forbidden)
          expect(response.body).to include("We don’t know which organisation you’re part of")
        end
      end
    end

    describe "GET show" do
      it "render providers show" do
        provider = build(:provider)
        current_recruitment_cycle = build(:recruitment_cycle)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
        stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}", provider.to_jsonapi)
        get(provider_path(provider.provider_code))
        expect(response.body).to include(provider.provider_name)
      end

      context "provider does not exist" do
        it "renders not found" do
          current_recruitment_cycle = build(:recruitment_cycle)
          stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
          stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/foo", {}, :get, 404)
          get(provider_path("foo"))
          expect(response.body).to include("Page not found")
        end
      end
    end

    describe "GET courses-as-an-accredited-body csv" do
      it "returns training provider courses" do
        training_provider = build(:provider)
        course = build(:course, provider: training_provider)
        accredited_provider = build(:provider, current_accredited_courses: [course])
        decorated_course = course.decorate
        stub_api_v2_request("/recruitment_cycles/#{accredited_provider.recruitment_cycle.year}", accredited_provider.recruitment_cycle.to_jsonapi)
        stub_api_v2_resource(accredited_provider)
        stub_api_v2_request(
          "/recruitment_cycles/#{accredited_provider.recruitment_cycle.year}/courses" \
          "?filter[accredited_body_code]=#{accredited_provider.provider_code}&include=provider",
          resource_list_to_jsonapi([course], include: :provider),
        )

        path = download_training_providers_courses_provider_recruitment_cycle_path(
          accredited_provider.provider_code,
          accredited_provider.recruitment_cycle.year,
          format: :csv,
        )
        get(path)

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(
          <<~HEREDOC,
            Provider code,Provider,Course code,Course,Study mode,Qualification,Status,View on Find,Applications open from,Vacancies
            #{course.provider.provider_code},#{course.provider.provider_name},#{course.course_code},#{course.name},#{decorated_course.study_mode.humanize},#{decorated_course.outcome},#{course.content_status.humanize},#{decorated_course.find_url},#{I18n.l(course.applications_open_from.to_date)},No
          HEREDOC
        )
      end
    end
  end

  context "when the user is not authenticated" do
    describe "GET suggest" do
      it "redirects to signin" do
        get "/providers/suggest"

        expect(response).to redirect_to("http://www.example.com/signin")
      end
    end

    describe "GET courses-as-an-accredited-body" do
      it "redirects to signin" do
        accredited_provider = build(:provider)

        path = download_training_providers_courses_provider_recruitment_cycle_path(
          accredited_provider.provider_code,
          accredited_provider.recruitment_cycle.year,
          format: :csv,
        )
        get(path)

        expect(response).to redirect_to("http://www.example.com/signin")
      end
    end
  end
end
