require "rails_helper"

feature "Show providers", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:provider) { build :provider }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider.recruitment_cycle)
  end

  context "When the provider is not accredited" do
    it "does not have show the courses as an accredited body link" do
      visit provider_path(provider.provider_code)
      expect { organisation_show_page.courses_as_accredited_body_link }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "When the provider is not accredited" do
    let(:provider) { build :provider, accredited_body?: true }

    it "does not have show the courses as an accredited body link" do
      visit provider_path(provider.provider_code)

      expect(organisation_show_page.courses_as_accredited_body_link.text).to eq("Courses as an accredited body")
    end
  end
end
