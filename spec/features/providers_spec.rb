require 'rails_helper'

RSpec.feature 'View providers', type: :feature do
  scenario 'Navigate to /organisations' do
    stub_omniauth
    stub_session_create
    stub_api_v2_request('/providers', 'providers.json')

    visit('/organisations')
    expect(find('h1')).to have_content('Organisations')
    expect(first('.govuk-list li')).to have_content('ACME SCITT 0')
  end
end
