require "rails_helper"

feature "sign-in interception" do
  context "when the signin intercept feature is enabled" do
    before do
      given_the_signin_intercept_feature_is_enabled
    end

    context "unauthenticated user" do
      it "redirects the user to the new session page" do
        given_i_am_an_unauthenticated_user
        when_i_visit_the_root_path
        then_i_am_redirected_to_the_new_session_page
      end
    end

    context "authenticated user" do
      it "does not redirect the user" do
        given_i_am_an_authenticated_user
        when_i_visit_the_root_path
        then_i_am_not_redirected_to_the_new_session_page
      end
    end
  end

  context "when signin intercept page feature is not enabled" do
    before do
      given_the_signin_intercept_feature_is_not_enabled
    end

    context "unauthenticated user" do
      it "redirects the user to DfE signin" do
        given_i_am_an_unauthenticated_user
        when_i_visit_the_root_path
        then_i_am_unauthorized
      end
    end

    context "authenticated user" do
      it "does not redirect the user" do
        given_i_am_an_authenticated_user
        when_i_visit_the_root_path
        then_i_am_not_redirected_to_dfe_signin
      end
    end
  end

  def given_the_signin_intercept_feature_is_enabled
    allow(Settings.features).to receive(:signin_intercept).and_return(true)
  end

  def given_the_signin_intercept_feature_is_not_enabled
    allow(Settings.features).to receive(:signin_intercept).and_return(false)
  end

  def given_i_am_an_authenticated_user
    stub_the_provider_index_requests
    stub_omniauth
    visit "/auth/dfe"
  end

  def given_i_am_an_unauthenticated_user
    # suppress STDOUT error messages
    OmniAuth.config.logger = Rails.logger
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = :invalid_credentials
    # oauth does this webfinger lookup https://tools.ietf.org/html/rfc7033
    stub_request(:get, "https://test-oidc.signin.education.gov.uk/.well-known/webfinger?rel=http://openid.net/specs/connect/1.0/issuer&resource=https://test-oidc.signin.education.gov.uk:443")
      .to_return(status: 200, body: "", headers: {})
  end

  def when_i_visit_the_root_path
    current_recruitment_cycle = build(:recruitment_cycle)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )

    visit root_path
  end

  def then_i_am_redirected_to_the_new_session_page
    expect(page.current_path).to eq(signin_path)
  end

  def then_i_am_not_redirected_to_the_new_session_page
    expect(page.current_path).to eq(root_path)
  end

  def then_i_am_unauthorized
    # We wouldn't expect a user to see this but just testing that the user is
    # redirected to signin doesn't seem to be possible so this at least tests
    # that when signin_intercept is disabled the usual Signin OAuth based auth
    # is still in place
    expect(page.current_path).to eq("/401")
  end

  def then_i_am_not_redirected_to_dfe_signin
    expect(page.current_path).to eq(root_path)
  end

  def stub_the_provider_index_requests
    current_recruitment_cycle = build(:recruitment_cycle)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )

    provider1 = build(:provider)
    provider2 = build(:provider)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers?page[page]=1",
      resource_list_to_jsonapi([provider1, provider2], meta: { count: 2 }),
    )
  end
end
