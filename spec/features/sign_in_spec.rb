require 'rails_helper'

feature 'Sign in', type: :feature do
  let(:transition_info_page) { PageObjects::Page::TransitionInfo.new }
  let(:organisations_page)   { PageObjects::Page::OrganisationsPage.new }
  let(:root_page)            { PageObjects::Page::RootPage.new }

  scenario 'using DfE Sign-in' do
    user = jsonapi :user

    stub_omniauth disable_completely: false,
                  user: user
    stub_api_v2_request('/providers', jsonapi(:providers_response))

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
    expect(root_page).to be_displayed
  end

  scenario 'new opted-in user accepts the transition info page' do
    user = jsonapi :user, :new, :opted_in

    stub_omniauth(user: user)
    stub_api_v2_request('/providers', jsonapi(:providers_response))
    request = stub_api_v2_request "/users/#{user.id}/accept_transition_screen", user, :patch

    visit '/signin'

    expect(transition_info_page).to be_displayed

    expect(transition_info_page.title).to have_content('Important new features')
    transition_info_page.continue.click

    expect(organisations_page).to be_displayed
    expect(request).to have_been_made
  end

  scenario 'new non-opted-in user accepts the transition info page' do
    user = jsonapi :user, :new

    stub_omniauth(user: user)
    stub_api_v2_request('/providers', jsonapi(:providers_response))

    visit '/signin'

    expect(transition_info_page).not_to be_displayed
    expect(root_page).to be_displayed
  end
end
