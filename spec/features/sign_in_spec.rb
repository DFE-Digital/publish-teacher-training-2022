require 'rails_helper'

RSpec.feature 'Sign in', type: :feature do
  scenario 'using DfE Sign-in' do
    stub_omniauth
    stub_session_create
    stub_backend_api

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (John Smith)")
  end
end
