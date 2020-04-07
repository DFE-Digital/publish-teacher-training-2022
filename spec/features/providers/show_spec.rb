require "rails_helper"

feature "Show providers", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:provider) { build :provider }
  let(:user) { build :user }
  let(:access_request) { build :access_request }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource_collection([access_request])
  end

  context "When the provider is not an accredited body" do
    it "does not have the courses as an accredited body link" do
      visit provider_path(provider.provider_code)
      expect(organisation_show_page).not_to have_courses_as_accredited_body_link
    end
  end

  context "When the provider is an accredited body" do
    let(:provider) { build :provider, accredited_body?: true }

    it "does have the courses as an accredited body link" do
      visit provider_path(provider.provider_code)
      expect(organisation_show_page.courses_as_accredited_body_link.text).to eq("Courses as an accredited body")
    end
  end
end
