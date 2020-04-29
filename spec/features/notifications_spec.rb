require "rails_helper"

feature "Notifications", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }

  let (:provider) { build :provider }
  let(:access_request) { build :access_request }
  # TODO: remove admin flag when we are ready to release to users
  let(:user) { build :user, admin: true }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource_collection([access_request])
  end

  context "When the provider is not an accredited body" do
    it "does not have the notifications link" do
      visit provider_path(provider.provider_code)
      expect(organisation_show_page).not_to have_notifications_preference_link
    end
  end

  context "When the provider is an accredited body" do
    let(:provider) { build :provider, accredited_body?: true }

    it "organisation page does have the notifications link" do
      visit provider_path(provider.provider_code)
      expect(organisation_show_page).to have_notifications_preference_link
    end
  end

end
