require 'rails_helper'

feature 'Sign in', type: :feature do
  let(:transition_info_page) { PageObjects::Page::TransitionInfo.new }
  let(:root_page)            { PageObjects::Page::RootPage.new }

  scenario 'using DfE Sign-in' do
    user = jsonapi :user

    stub_omniauth disable_completely: false,
                  user: user
    stub_session_create user: user.to_resource
    stub_api_v2_request('/providers', jsonapi(:providers_response))

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
    expect(root_page).to be_displayed
  end

  scenario 'new user accepts the transition info page' do
    user = jsonapi :user, :new

    stub_omniauth(user: user)
    stub_session_create(user: user)
    stub_api_v2_request('/providers', jsonapi(:providers_response))
    stub_api_v2_request '/sessions', user, :post

    visit '/signin'

    expect(transition_info_page).to be_displayed
  end
end
