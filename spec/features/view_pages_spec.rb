require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario "Navigate to home" do
    stub_omniauth
    stub_session_create
    stub_backend_api

    visit "/pages/home"
    # Redirect to DfE Signin and come back
    expect(page).to have_text("Sign out (John Smith)")
  end
end
