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

  context "When the provider is not accredited" do
    it "does not have show the courses as an accredited body link" do
      visit provider_path(provider.provider_code)
      expect { organisation_show_page.courses_as_accredited_body_link }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "When the provider is accredited" do
    let(:provider) { build :provider, accredited_body?: true }

    context "and the user is not an admin"  do
      it "does not have show the courses as an accredited body link" do
        visit provider_path(provider.provider_code)
        expect { organisation_show_page.courses_as_accredited_body_link }.to raise_error(Capybara::ElementNotFound)
      end
    end

    context "and the user is an admin" do
      let(:user) { build :user, :admin }

      it "does shows the courses as an accredited body link" do
        visit provider_path(provider.provider_code)
        expect(organisation_show_page.courses_as_accredited_body_link.text).to eq("Courses as an accredited body")
      end
    end
  end
end
