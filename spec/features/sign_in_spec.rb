require "rails_helper"

feature "Sign in", type: :feature do
  describe "sign in page is rendered" do
    let(:sign_in_page) { PageObjects::Page::SignIn.new }

    before do
      sign_in_page.load
    end
    context "when mode is persona", authentication_mode: :persona do
      context "when basic_auth disabled is false" do
        before do
          allow(Settings.authentication.basic_auth).to receive(:disabled).and_return(true)
          sign_in_page.load
        end

        scenario "navigate to sign in" do
          expect(sign_in_page.page_heading).to have_text("Sign in")
          expect(sign_in_page).to have_title("Sign in - Publish teacher training courses - GOV.UK")
          expect(sign_in_page.sign_in_button.text).to eq("Sign in using a Persona")
        end
      end
    end

    context "when mode is dfe_signin", authentication_mode: :dfe_signin do
      scenario "navigate to sign in" do
        expect(sign_in_page.page_heading).to have_text("Sign in")
        expect(sign_in_page).to have_title("Sign in - Publish teacher training courses - GOV.UK")
        expect(sign_in_page.sign_in_button.value).to eq("Sign in using DfE Sign-in")
      end
    end

    context "when mode is magic_link", authentication_mode: :magic_link do
      scenario "navigate to sign in" do
        expect(sign_in_page.page_heading).to have_text("Sign in")
        expect(sign_in_page).to have_title("Sign in - Publish teacher training courses - GOV.UK")
        expect(sign_in_page.sign_in_button.value).to eq("Continue")
      end
    end
  end

  describe "signing in" do
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

    def visit_dfe_sign_in(url)
      visit url

      if url != sign_in_path
        expect(page.current_path).to eq sign_in_path
      end
      click_button("Sign in using DfE Sign-in")
    end

    scenario "using DfE Sign-in" do
      user = build(:user, :transitioned)
      stub_omniauth(user: user)
      stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)

      visit_dfe_sign_in(root_path)

      expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
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
            "#{Settings.teacher_training_api.base_url}/api/v2/users/#{user.id}",
          )
            .with(body: /"state":"transitioned"/)
        end
        let(:user_get_request) { stub_api_v2_request("/users/#{user.id}", user.to_jsonapi) }

        before do
          user_get_request
          user_update_request
        end

        scenario "new user accepts the transition info page" do
          visit_dfe_sign_in("/signin")

          expect(transition_info_page).to be_displayed
          expect(transition_info_page.title).to have_content("Important new features")

          transition_info_page.continue.click

          expect(root_page).to be_displayed
          expect(user_update_request).to have_been_made
        end
      end
    end

    describe "maintenance mode" do
      before do
        allow(Settings.features.maintenance_mode).to receive(:enabled).and_return(true)
        allow(Settings.features.maintenance_mode).to receive(:title).and_return("Maintenance message title")
        allow(Settings.features.maintenance_mode).to receive(:body).and_return("Maintenance message body")
      end

      describe "not signed in" do
        it "redirects to sign in page with maintenance message" do
          visit "/"
          expect(page.current_path).to eq sign_in_path
          expect(page).to have_content("Sign in")
          expect(page).to have_content("Maintenance message title")
          expect(page).to have_content("Maintenance message body")
        end
      end

      describe "non-admin user" do
        it "after sign in redirects to sign in page with maintenance message" do
          user = build(:user)
          stub_omniauth(user: user)
          stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)

          visit_dfe_sign_in(root_path)

          expect(page.current_path).to eq sign_in_path
          expect(page).to have_content("Sign in")
          expect(page).to have_content("Maintenance message title")
          expect(page).to have_content("Maintenance message body")
          expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
        end
      end

      describe "admin user" do
        it "allows sign in without redirecting to sign in page" do
          user = build(:user, :admin)
          stub_omniauth(user: user)
          stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)
          stub_api_v2_request("/access_requests", nil, :get)

          visit_dfe_sign_in(root_path)

          expect(page.current_path).to eq root_path
          expect(page).to_not have_content("Sign in to Publish teaching training")
          expect(page).to_not have_content("Maintenance message title")
          expect(page).to_not have_content("Maintenance message body")
          expect(page).to have_content("Organisations")
          expect(page).to have_content("Sign out (#{user.first_name} #{user.last_name})")
        end
      end
    end

    scenario "new inactive user accepts the terms and conditions page with rollover disabled" do
      allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
      user = build(:user, :inactive, :new)
      accepted_user = build(:user, user.attributes)
      accepted_user.accept_terms_date_utc = 1.second.ago
      stub_api_v2_request("/users/#{user.id}/accept_terms", accepted_user.to_jsonapi, :patch)

      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers",
        {
          meta: {
            error_type: "user_not_accepted_terms_and_conditions",
          },
        },
        :get,
        403,
      )

      stub_omniauth(user: user)

      visit_dfe_sign_in("/signin")
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
end
