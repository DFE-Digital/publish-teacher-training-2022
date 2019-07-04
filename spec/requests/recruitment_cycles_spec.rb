require 'rails_helper'

describe 'Recruitment cycles' do
  describe 'GET show' do
    let(:provider) { jsonapi(:provider) }

    it 'redirects to the course index page' do
      stub_omniauth
      get(auth_dfe_callback_path)
      get("/organisations/#{provider.provider_code}/courses")
      expect(response).to redirect_to(provider_recruitment_cycle_courses_path(provider.provider_code, '2019'))
    end
  end
end
