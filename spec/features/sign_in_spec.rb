require 'rails_helper'

RSpec.feature 'Sign in', type: :feature do
  scenario 'using DfE Sign-in' do
    user = jsonapi :user, :new

    stub_omniauth disable_completely: false,
                  user: user
    stub_session_create user: user.to_resource
    stub_api_v2_request('/providers', jsonapi(:providers_response))

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
  end
end
