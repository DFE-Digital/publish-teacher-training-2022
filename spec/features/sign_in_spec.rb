require 'rails_helper'

feature 'Sign in', type: :feature do
  let(:transition_info_page) { PageObjects::Page::TransitionInfo.new }
  let(:rollover_page)        { PageObjects::Page::Rollover.new }
  let(:accept_terms_page)    { PageObjects::Page::AcceptTerms.new }
  let(:organisations_page)   { PageObjects::Page::OrganisationsPage.new }
  let(:root_page)            { PageObjects::Page::RootPage.new }
  let(:providers) do
    [
      build(:provider, courses: [build(:course)]),
      build(:provider, courses: [build(:course)]),
      build(:provider, courses: [build(:course)])
    ]
  end

  let(:current_recruitment_cycle) { build(:recruitment_cycle, year: 2019) }

  let(:providers_response) do
    resource_list_to_jsonapi(providers)
  end

  before do
    stub_api_v2_request(
      "/recruitment_cycles/2019",
      current_recruitment_cycle.to_jsonapi
    )
  end

  scenario 'using DfE Sign-in' do
    allow(Settings).to receive(:rollover).and_return(true)
    user = build :user

    stub_omniauth(user: user)
    stub_api_v2_request('/recruitment_cycles/2019/providers',
                        providers_response)

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
    expect(root_page).to be_displayed
  end

  scenario 'new user accepts the transition info page' do
    user = build :user, :new

    stub_omniauth(user: user)
    stub_api_v2_request('/recruitment_cycles/2019/providers', providers_response)
    request = stub_api_v2_request "/users/#{user.id}/accept_transition_screen", user.to_jsonapi, :patch

    visit '/signin'

    expect(transition_info_page).to be_displayed

    expect(transition_info_page.title).to have_content('Important new features')
    transition_info_page.continue.click

    expect(rollover_page).to be_displayed
    expect(request).to have_been_made
  end

  scenario 'new user accepts the transition info page with rollover disabled' do
    allow(Settings).to receive(:rollover).and_return(false)
    user = build :user, :new

    stub_omniauth(user: user)
    stub_api_v2_request('/recruitment_cycles/2019/providers', providers_response)
    request = stub_api_v2_request "/users/#{user.id}/accept_transition_screen", user.to_jsonapi, :patch

    visit '/signin'

    expect(transition_info_page).to be_displayed

    expect(transition_info_page.title).to have_content('Important new features')
    transition_info_page.continue.click

    expect(organisations_page).to be_displayed
    expect(request).to have_been_made
  end

  scenario 'new user accepts the rollover page' do
    user = build :user, :transitioned

    stub_omniauth(user: user)
    stub_api_v2_request('/recruitment_cycles/2019/providers', providers_response)
    request = stub_api_v2_request "/users/#{user.id}/accept_rollover_screen", user.to_jsonapi, :patch

    visit '/signin'

    expect(rollover_page).to be_displayed

    expect(rollover_page.title).to have_content('Begin preparing for the next cycle')
    rollover_page.continue.click

    expect(organisations_page).to be_displayed
    expect(request).to have_been_made
  end

  scenario 'new inactive user accepts the terms and conditions page with rollover disabled' do
    allow(Settings).to receive(:rollover).and_return(false)
    user = build :user, :inactive, :new

    stub_api_v2_request(
      "/recruitment_cycles/2019",
      current_recruitment_cycle.to_jsonapi,
      :get, 403
    )

    stub_omniauth(user: user)
    stub_api_v2_request('/recruitment_cycles/2019/providers', providers_response)
    request = stub_api_v2_request "/users/#{user.id}/accept_terms", user.to_jsonapi, :patch

    visit '/signin'

    stub_api_v2_request(
      "/recruitment_cycles/2019",
      current_recruitment_cycle.to_jsonapi
    )

    expect(accept_terms_page).to be_displayed

    expect(accept_terms_page.title).to have_content('Before you begin')
    accept_terms_page.continue.click

    expect(accept_terms_page).to be_displayed

    expect(accept_terms_page).to have_content('You must accept the terms')
    check('I agree to the terms and conditions')
    accept_terms_page.continue.click

    expect(transition_info_page).to be_displayed
    expect(request).to have_been_made
  end
end
