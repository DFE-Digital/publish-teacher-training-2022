require "rails_helper"

describe 'sessions' do
  let(:provider) { jsonapi :provider }
  let(:provider_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:root_page) { PageObjects::Page::RootPage.new }

  it 'redirects users back to where they were going on sign-in' do
    stub_omniauth disable_completely: false
    stub_session_create
    stub_api_v2_request('/providers', jsonapi(:providers_response))
    stub_api_v2_request("/providers/#{provider.provider_code}", provider.render)

    visit "/organisations/#{provider.provider_code}"

    expect(provider_page).to be_displayed(provider_code: provider.provider_code)
  end

  it 'redirects users to root when they go straight to the signin page' do
    stub_omniauth disable_completely: false
    stub_session_create
    stub_api_v2_request('/providers', jsonapi(:providers_response))

    visit '/signin'

    expect(root_page).to be_displayed
  end
end
