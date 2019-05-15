require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario "Navigate to /cookies" do
    stub_omniauth

    visit "/cookies"
    expect(find('h1')).to have_content('Cookies')
  end

  scenario "Navigate to /terms-conditions" do
    stub_omniauth

    visit "/terms-conditions"
    expect(find('h1')).to have_content('Terms and Conditions')
  end

  scenario "Navigate to /privacy-policy" do
    stub_omniauth

    visit "/privacy-policy"
    expect(find('h1')).to have_content('Privacy policy')
  end

  scenario "Navigate to /guidance" do
    visit "/guidance"
    expect(find('h1')).to have_content('Guidance for Publish teacher training courses')
  end
end
