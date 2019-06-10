require 'rails_helper'

describe 'Courses' do
  describe 'POST publish' do
    let(:provider) { jsonapi(:provider) }
    let(:course) { jsonapi(:course, provider: provider) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course.render,
      )
    end

    context "without errors" do
      before do
        stub_api_v2_request(
          "/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
          nil,
          :post
        )
        post publish_provider_course_path(provider_code: provider.provider_code, code: course.course_code)
      end

      it 'redirects to the course description page' do
        expect(flash[:success]).to include('Your course has been published')
        expect(response).to redirect_to(description_provider_course_path(provider_code: provider.provider_code, code: course.course_code))
      end
    end

    context "with errors" do
      before do
        stub_api_v2_request(
          "/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
          build(:error, :for_course_publish),
          :post,
          422
        )
        post publish_provider_course_path(provider_code: provider.provider_code, code: course.course_code)
      end

      it 'redirects to the course description page' do
        expect(flash[:error_summary]).to eq("about_course" => "About course can't be blank")
        expect(response).to redirect_to(description_provider_course_path(provider_code: provider.provider_code, code: course.course_code))
      end
    end
  end
end
