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

  scenario "Navigate to /guidance" do
    visit "/guidance"
    expect(find('h1')).to have_content('Guidance for Publish teacher training courses')
  end

  scenario "Navigate to /transition" do
    stub_omniauth
    stub_session_create

    visit "/transition"
    expect(find('h1')).to have_content('Important new features')
    expect(page).to have_link('Continue')
  end
end
