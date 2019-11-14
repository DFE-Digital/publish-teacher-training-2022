require "rails_helper"

feature "Access Requests", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
  end

  describe "admin access request creation page" do
    let(:new_manual_access_request_page) { PageObjects::Page::Organisations::NewManualAccessRequestPage.new }
    let(:confirm_access_requests_page) { PageObjects::Page::Organisations::ConfirmAccessRequestsPage.new }
    let(:list_access_requests_page) { PageObjects::Page::Organisations::ListAccessRequestsPage.new }

    let(:organisation) { build(:organisation) }
    let(:user) { build(:user, organisations: [organisation]) }
    let(:access_request) do
      build(:access_request,
            requester: user,
            requester_email: "v.vincent@pauli.edu",
            first_name: "Howard",
            last_name: "Kyoma",
            email_address: "h.kyoma@pauli.edu",
            reason: "Manual creation by user support agent")
    end

    before do
      stub_api_v2_resource(access_request, include: "requester,requester.organisations")
      stub_api_v2_resource_collection([access_request], include: "requester")
      stub_api_v2_request("/access_requests/#{access_request.id}/approve", nil, :post)
    end

    it "can create an access request" do
      access_request_submission_stub = stub_api_v2_resource(access_request, method: :post) do |body|
        expect(body["data"]["attributes"]).to eq(
          "first_name" => "Howard",
          "last_name" => "Kyoma",
          "email_address" => "h.kyoma@pauli.edu",
          "requester_email" => "v.vincent@pauli.edu",
          "reason" => "Manual creation by user support agent",
          #It seems like nothing actually uses this organisation thing, it's just use for display which makes it misleading
          "organisation" => "Department for Education",
        )
      end
      visit new_manual_access_requests_path

      new_manual_access_request_page.requester_email.set("v.vincent@pauli.edu")
      new_manual_access_request_page.email_address.set("h.kyoma@pauli.edu")
      new_manual_access_request_page.first_name.set("Howard")
      new_manual_access_request_page.last_name.set("Kyoma")
      new_manual_access_request_page.preview.click
      expect(confirm_access_requests_page).to be_displayed
      confirm_access_requests_page.approve.click
      expect(access_request_submission_stub).to have_been_requested
      expect(list_access_requests_page).to be_displayed
    end
  end

  describe "index page" do
    let(:list_access_requests_page) { PageObjects::Page::Organisations::ListAccessRequestsPage.new }
    let(:confirm_access_requests_page) { PageObjects::Page::Organisations::ConfirmAccessRequestsPage.new }
    let(:organisation) { build(:organisation) }
    let(:user) { build(:user, organisations: [organisation]) }
    let(:access_request) do
      build(:access_request,
            requester: user,
            request_date_utc: Date.new(2019, 11, 11),
            first_name: "Allen",
            last_name: "Swartz",
            email_address: "aswartz@mymail.co",
            organisation: "Aleph Null Academy")
    end

    before do
      stub_api_v2_resource(access_request, include: "requester,requester.organisations")
      stub_api_v2_resource_collection([access_request], include: "requester")
    end

    it "lists all access requests" do
      visit access_requests_path
      expect(list_access_requests_page.access_requests.count).to eq(1)
      expect(list_access_requests_page.access_requests.first.request_date).to have_content("November 11, 2019")
      expect(list_access_requests_page.access_requests.first.recipient).to have_content("Allen Swartz <aswartz@mymail.co>")
      expect(list_access_requests_page.access_requests.first.organisation).to have_content("Aleph Null Academy")
    end

    it "can approve a request" do
      submitted_access_request = stub_api_v2_request("/access_requests/#{access_request.id}/approve", nil, :post)

      visit access_requests_path
      list_access_requests_page.access_requests.first.approve.click
      expect(confirm_access_requests_page).to be_displayed
      confirm_access_requests_page.approve.click
      expect(submitted_access_request).to have_been_requested
      expect(list_access_requests_page).to be_displayed
    end
  end

  context "without validation errors" do
    before do
      stub_api_v2_request("/access_requests", nil, :post)
      stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}",
        provider.to_jsonapi,
      )
    end

    scenario "Requesting access for a user" do
      visit request_access_provider_path(provider.provider_code)

      fill_in "First name", with: "John"
      fill_in "Last name", with: "Cleese"
      fill_in "Email address", with: "john.cleese@bbc.co.uk"
      fill_in "Their organisation", with: "BBC"
      fill_in "Reason they need access", with: "It's John Cleese mate let him in"

      click_on "Request access"

      expect(page).to have_content("Your request for access has been submitted")
    end
  end

  context "with validations errors" do
    before do
      stub_api_v2_request(
        "/access_requests", build(:error, :for_access_request_create), :post, 422
      )
    end

    scenario "Requesting access for a user" do
      visit request_access_provider_path(provider.provider_code)

      click_on "Request access"

      expect(page).to have_content("Enter your first name")
    end
  end
end
