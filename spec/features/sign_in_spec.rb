require 'rails_helper'

feature 'Sign in', type: :feature do
  let(:transition_info_page) { PageObjects::Page::TransitionInfo.new }
  let(:rollover_page)        { PageObjects::Page::Rollover.new }
  let(:organisations_page)   { PageObjects::Page::OrganisationsPage.new }
  let(:root_page)            { PageObjects::Page::RootPage.new }

  scenario 'using DfE Sign-in' do
    user = build :user

    stub_omniauth(user: user)
    stub_api_v2_request('/providers', jsonapi(:providers_response))

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
    expect(root_page).to be_displayed
  end

  context 'not during rollover' do
    before do
      allow(Settings).to receive(:rollover).and_return(false)
    end

    scenario 'new user accepts the transition info page with rollover disabled' do
      user = build :user, :new

      stub_omniauth(user: user)
      stub_api_v2_request('/providers', jsonapi(:providers_response))
      request = stub_api_v2_request "/users/#{user.id}/accept_transition_screen", user.to_jsonapi, :patch

      visit '/signin'

      expect(transition_info_page).to be_displayed

      expect(transition_info_page.title).to have_content('Important new features')
      transition_info_page.continue.click

      expect(organisations_page).to be_displayed
      expect(request).to have_been_made
    end
  end

  context 'during rollover' do
    before do
      allow(Settings).to receive(:rollover).and_return(true)
    end

    scenario 'new user accepts the transition info page' do
      user = build :user, :new

      stub_omniauth(user: user)
      stub_api_v2_request('/providers', jsonapi(:providers_response))
      request = stub_api_v2_request "/users/#{user.id}/accept_transition_screen", user.to_jsonapi, :patch

      visit '/signin'

      expect(transition_info_page).to be_displayed

      expect(transition_info_page.title).to have_content('Important new features')
      transition_info_page.continue.click

      expect(rollover_page).to be_displayed
      expect(request).to have_been_made
    end

    scenario 'new user accepts the rollover page' do
      user = build :user, :transitioned

      stub_omniauth(user: user)
      stub_api_v2_request('/providers', jsonapi(:providers_response))
      request = stub_api_v2_request "/users/#{user.id}/accept_rollover_screen", user.to_jsonapi, :patch

      visit '/signin'

      expect(rollover_page).to be_displayed

      expect(rollover_page.title).to have_content('Begin preparing for the next cycle')
      rollover_page.continue.click

      expect(organisations_page).to be_displayed
      expect(request).to have_been_made
    end
  end
end
