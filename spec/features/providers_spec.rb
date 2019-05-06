require 'rails_helper'

RSpec.feature 'View providers', type: :feature do
  let(:provider1) { jsonapi :provider, provider_code: 'A0', include_counts: [:courses] }
  let(:provider2) { jsonapi :provider, provider_code: 'A1', include_counts: [:courses] }
  let(:provider_response) { provider1.render }
  let(:providers_response) {
    jsonapi(:providers_response, data: [provider1.render[:data], provider2.render[:data]])
  }

  scenario 'Navigate to /organisations' do
    stub_omniauth
    stub_api_v2_request('/providers', providers_response)

    visit('/organisations')
    expect(find('h1')).to have_content('Organisations')
    expect(first('.govuk-list li')).to have_content(provider1.provider_name.to_s)
  end


  scenario 'Navigate to /organisations/AO' do
    stub_omniauth
    stub_api_v2_request('/providers/A0', provider_response)

    visit('/organisations/A0')
    expect(find('h1')).to have_content(provider1.provider_name.to_s)
    expect(page).to_not have_selector(".govuk-breadcrumbs")
    expect(page).to have_link('Locations', href: '/organisations/A0/locations')
    expect(page).to have_link('Courses', href: '/organisations/A0/courses')
  end
end
