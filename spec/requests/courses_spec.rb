require 'rails_helper'

describe 'Courses' do
  describe 'POST publish' do
    let(:provider) { jsonapi(:provider) }
    let(:course) { jsonapi(:course, provider: provider) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
        course.render,
      )
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}/publish",
        nil,
        :post
      )
      post publish_provider_course_path(provider_code: provider.provider_code, code: course.course_code)
    end

    it 'redirects to the course description page' do
      expect(response).to redirect_to(description_provider_course_path(provider_code: provider.provider_code, code: course.course_code))
    end
  end
end
