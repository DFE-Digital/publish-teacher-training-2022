require 'rails_helper'

RSpec.feature 'View providers', type: :feature do
  scenario 'Navigate to /organisations' do
    stub_omniauth
    stub_session_create
    stub_api_v2_request('/providers', build(:providers_response))

    visit('/organisations')
    expect(find('h1')).to have_content('Organisations')
    expect(first('.govuk-list li')).to have_content('ACME SCITT A0')
  end

  scenario 'Navigate to /organisations/AO' do
    stub_omniauth
    stub_session_create
    stub_api_v2_request('/providers', build(:providers_response, data: [build(:provider, institution_code: "A0")]))
    stub_api_v2_request('/providers/A0', build(:providers_response, data: [build(:provider, institution_code: "A0")]))

    visit('/organisations/A0')
    expect(find('h1')).to have_content('ACME SCITT A0')
    expect(page).to have_selector(".govuk-breadcrumbs")
  end
end
