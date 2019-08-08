require 'rails_helper'

feature 'Access Requests', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle, year: '2019') }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
  end

  context 'without validation errors' do
    before do
      stub_api_v2_request("/access_requests", nil, :post)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}",
        provider.to_jsonapi
      )
    end

    scenario 'Requesting access for a user' do
      visit request_access_provider_path(provider.provider_code)

      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Cleese'
      fill_in 'Email address', with: 'john.cleese@bbc.co.uk'
      fill_in 'Their organisation', with: 'BBC'
      fill_in 'Reason they need access', with: "It's John Cleese mate let him in"

      click_on 'Request access'

      expect(page).to have_content('Your request for access has been submitted')
    end
  end

  context "with validations errors" do
    before do
      stub_api_v2_request(
        "/access_requests", build(:error, :for_access_request_create), :post, 422
      )
    end

    scenario 'Requesting access for a user' do
      visit request_access_provider_path(provider.provider_code)

      click_on 'Request access'

      expect(page).to have_content('Enter your first name')
    end
  end
end
