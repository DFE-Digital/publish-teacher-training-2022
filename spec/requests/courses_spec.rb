require 'rails_helper'

describe 'Courses' do
  describe 'POST publish' do
    let(:current_recruitment_cycle) { jsonapi(:recruitment_cycle, year:'2019') }
    let(:provider) { jsonapi(:provider, provider_code: 'A0') }
    let(:course) { jsonapi(:course, provider: provider) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.render)
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course.render,
      )
    end

    context "without errors" do
      before do
        stub_api_v2_request(
          "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
          nil,
          :post
        )
        post publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
      end

      it 'redirects to the course description page' do
        expect(flash[:success]).to include('Your course has been published')
        expect(response).to redirect_to(provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code))
      end
    end

    context "with errors" do
      before do
        stub_api_v2_request(
          "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
          build(:error, :for_course_publish),
          :post,
          422
        )
        post publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
      end

      it 'redirects to the course description page' do
        expect(flash[:error_summary]).to eq(about_course: ["About course can't be blank"])
        expect(response).to redirect_to(provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code))
      end
    end
  end
end
