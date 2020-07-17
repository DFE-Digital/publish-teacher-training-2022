require "rails_helper"

describe "Courses" do
  describe "POST publish" do
    let(:current_recruitment_cycle) { build(:recruitment_cycle) }
    let(:provider) { build(:provider, provider_code: "A0") }
    let(:course) { build(:course, provider: provider, recruitment_cycle: current_recruitment_cycle) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_resource(current_recruitment_cycle)
      stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(provider)
    end

    describe "GET search" do
      it "renders providers search" do
        stub_api_v2_resource(course, include: "accrediting_provider")
        build(:recruitment_cycle)
        provider1 = build(:provider, provider_name: "asd")
        provider2 = build(:provider, provider_name: "aoe")
        stub_api_v2_request("/providers/suggest_any?query=a&filter[only_accredited_body]=true", resource_list_to_jsonapi([provider1, provider2]))
        get(accredited_body_search_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code, query: "a"))
        expect(response.body).to include("asd")
        expect(response.body).to include("aoe")
      end
    end

    context "without errors" do
      before do
        stub_api_v2_request(
          "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
          nil,
          :post,
        )
        post publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
      end

      it "redirects to the course description page" do
        expect(flash[:success]).to include("Your course has been published")
        expect(response).to redirect_to(provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code))
      end
    end

    context "with errors" do
      before do
        stub_api_v2_request(
          "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
          build(:error, :for_course_publish),
          :post,
          422,
        )
        post publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
      end

      it "displays errors" do
        response.body.include?("About course can&#39;t be blank")
      end
    end
  end
end
