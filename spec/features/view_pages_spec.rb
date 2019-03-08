require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario "Navigate to /cookies" do
    stub_omniauth
    stub_session_create

    visit "/cookies"
    expect(find('h1')).to have_content('Cookies')
  end

  scenario "Navigate to /terms-conditions" do
    stub_omniauth
    stub_session_create

    visit "/terms-conditions"
    expect(find('h1')).to have_content('Terms and Conditions')
  end

  scenario "Navigate to /privacy-policy" do
    stub_omniauth
    stub_session_create

    visit "/privacy-policy"
    expect(find('h1')).to have_content('Privacy policy')
  end
end
