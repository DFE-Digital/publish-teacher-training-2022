require "rails_helper"

feature "Sign in", type: :feature do
  let(:transition_info_page)      { PageObjects::Page::TransitionInfo.new }
  let(:notifications_info_page)   { PageObjects::Page::NotificationsInfo.new }
  let(:rollover_page)             { PageObjects::Page::Rollover.new }
  let(:rollover_recruitment_page) { PageObjects::Page::RolloverRecruitment.new }
  let(:accept_terms_page)         { PageObjects::Page::AcceptTerms.new }
  let(:organisations_page)        { PageObjects::Page::OrganisationsPage.new }
  let(:root_page)                 { PageObjects::Page::RootPage.new }
  let(:providers) do
    [
      build(:provider, courses: [build(:course)]),
      build(:provider, courses: [build(:course)]),
      build(:provider, courses: [build(:course)]),
    ]
  end

  let(:current_recruitment_cycle) { build(:recruitment_cycle) }

  let(:providers_response) do
    resource_list_to_jsonapi(providers, meta: { count: 3 })
  end

  before do
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers?page[page]=1",
      providers_response,
    )
  end

  scenario "using DfE Sign-in" do
    user = build(:user)
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
    stub_omniauth(user: user)
    stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
    expect(page.current_path).to eql("/rollover")
  end

  describe "Interruption screens" do
    before do
      stub_omniauth(user: user)
    end

    describe "transition screen" do
      let(:user) { build(:user, :new) }
      let(:user_update_request) do
        stub_request(
          :patch,
          "#{Settings.manage_backend.base_url}/api/v2/users/#{user.id}",
        )
                                    .with(body: /"state":"transitioned"/)
      end
      let(:user_get_request) { stub_api_v2_request("/users/#{user.id}", user.to_jsonapi) }

      before do
        user_get_request
        user_update_request
      end

      context "Rollover is enabled" do
        let(:user) { build(:user, :new) }
        let(:transitioned_user) { build(:user, :transitioned, id: user.id) }

        let(:user_update_request) do
          stub_request(
            :patch,
            "#{Settings.manage_backend.base_url}/api/v2/users/#{user.id}",
          )
                                      .with(body: /"state":"transitioned"/)
        end

        let(:user_get_request) do
          stub_request(:get, "#{Settings.manage_backend.base_url}/api/v2/users/#{user.id}").to_return(
            { body: user.to_jsonapi.to_json, headers: { 'Content-Type': "application/vnd.api+json" } },
            { body: user.to_jsonapi.to_json, headers: { 'Content-Type': "application/vnd.api+json" } },
            { body: transitioned_user.to_jsonapi.to_json, headers: { 'Content-Type': "application/vnd.api+json" } },
          )
        end

        before do
          user_get_request
          user_update_request
          allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
        end

        scenario "new user accepts the transition info page" do
          visit "/signin"

          expect(transition_info_page).to be_displayed
          expect(transition_info_page.title).to have_content("Important new features")

          transition_info_page.continue.click

          expect(rollover_page).to be_displayed
          expect(user_update_request).to have_been_made
        end
      end

      context "Roll over is disabled" do
        before do
          allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
        end

        scenario "new user accepts the transition info page" do
          visit "/signin"

          expect(transition_info_page).to be_displayed
          expect(transition_info_page.title).to have_content("Important new features")

          transition_info_page.continue.click

          expect(root_page).to be_displayed
          expect(user_update_request).to have_been_made
        end
      end
    end

    describe "rollover screen" do
      let(:user) { build(:user, :transitioned) }
      let(:user_update_request) do
        stub_request(
          :patch,
          "#{Settings.manage_backend.base_url}/api/v2/users/#{user.id}",
        ).with(body: /"state":"accepted_rollover_2021"/)
      end
      let(:user_get_request) { stub_api_v2_request("/users/#{user.id}", user.to_jsonapi) }

      before do
        user_get_request
        user_update_request
        allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
      end

      scenario "new user accepts the rollover page" do
        visit "/signin"

        expect(rollover_page).to be_displayed

        expect(rollover_page.title).to have_content("Prepare for the next cycle")
        rollover_page.continue.click

        expect(rollover_recruitment_page).to be_displayed
        expect(rollover_recruitment_page.title).to have_content("Recruiting for the 2021 - 2022 cycle")
        rollover_recruitment_page.continue.click

        expect(root_page).to be_displayed
        expect(user_update_request).to have_been_made
      end
    end

    describe "notifications screen" do
      let(:user) { build(:user, :rolled_over, associated_with_accredited_body: true, notifications_configured: false) }
      let(:user_update_request) do
        stub_request(
          :patch,
          "#{Settings.manage_backend.base_url}/api/v2/users/#{user.id}",
        )
                                    .with(body: /"state":"notifications_configured"/)
      end
      let(:user_get_request) { stub_api_v2_request("/users/#{user.id}", user.to_jsonapi) }

      before do
        user_get_request
        user_update_request
      end

      scenario "accredited body user accepts the new accredited body features page" do
        visit "/signin"

        expect(notifications_info_page).to be_displayed

        expect(notifications_info_page).to have_content("Get notifications about your courses")
        notifications_info_page.continue.click

        expect(root_page).to be_displayed
        expect(user_update_request).to have_been_made
      end
    end
  end

  scenario "new inactive user accepts the terms and conditions page with rollover disabled" do
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
    user = build(:user, :inactive, :new)
    accepted_user = build(:user, user.attributes)
    accepted_user.accept_terms_date_utc = 1.second.ago
    stub_api_v2_request("/users/#{user.id}/accept_terms", accepted_user.to_jsonapi, :patch)

    stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)

    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      {
        meta: {
          error_type: "user_not_accepted_terms_and_conditions",
        },
      },
      :get,
      403,
    )

    stub_omniauth(user: user)

    visit "/signin"

    expect(accept_terms_page).to be_displayed

    expect(accept_terms_page.title).to have_content("Before you begin")
    accept_terms_page.continue.click

    expect(accept_terms_page).to be_displayed

    expect(accept_terms_page).to have_content("You must accept the terms")
    check("I agree to the terms and conditions")
    accept_terms_page.continue.click

    expect(transition_info_page).to be_displayed
  end
end
