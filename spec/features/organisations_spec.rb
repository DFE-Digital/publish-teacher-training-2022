require "rails_helper"

feature "View organisations", type: :feature do
  let(:home_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:organisation_page) { PageObjects::Page::OrganisationsPage.new }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:user) do
    build :user,
          admin: true,
          first_name: "Adam",
          last_name: "Smith",
          email: "adam.smith@bigscitt.org",
          sign_in_user_id: "123456"
  end
  let(:provider) { build :provider }
  let(:organisation) { build :organisation, name: "Big Scitt", providers: [provider], users: [user] }
  let(:access_request) { build(:access_request) }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource_collection([organisation], include: "providers,users")
    stub_api_v2_resource_collection([access_request], include: "requester")
    stub_api_v2_resource_collection([access_request])
  end

  describe "page header" do
    context "user is admin" do
      it "links to the organisations page" do
        visit provider_courses_path(provider.provider_code)
        home_page.organisations_link.click
        expect(organisation_page).to be_displayed
      end
    end

    context "user is not admin" do
      let(:non_admin_user) { build(:user, admin: false, organisations: [organisation]) }
      before do
        stub_omniauth(user: non_admin_user)
      end

      it "does not link to the organisations page" do
        visit provider_courses_path(provider.provider_code)
        expect(home_page).not_to have_organisations_link
      end
    end
  end

  describe "organisations with active users" do
    it "lists all users by organisation" do
      visit "/organisations-support-page"
      expect(find("h1")).to have_content("Active users by organisation")
      expect(organisation_page.organisations.first.name).to have_content(organisation.name)
      expect(organisation_page.organisations.first.users).to have_link(
        "Adam Smith <adam.smith@bigscitt.org>",
        href: "#{Settings.dfe_signin.user_search_url}/123456/audit",
      )

      expect(organisation_page.organisations.first.providers).to have_content(provider.provider_name)
    end
  end
end
