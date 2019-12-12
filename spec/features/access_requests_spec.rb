require "rails_helper"

feature "Access Requests", type: :feature do
  let(:new_access_request_page) { PageObjects::Page::Organisations::NewManualAccessRequestPage.new }
  let(:list_access_requests_page) { PageObjects::Page::Organisations::ListAccessRequestsPage.new }
  let(:confirm_access_requests_page) { PageObjects::Page::Organisations::ConfirmAccessRequestsPage.new }
  let(:inform_publisher_page) { PageObjects::Page::Organisations::InformPublisherPage.new }
  let(:organisations_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider) }
  let(:organisation) { build(:organisation) }
  let(:user) { build(:user, organisations: [organisation]) }

  let(:submitted_access_request) { stub_api_v2_request("/access_requests/#{access_request.id}/approve", nil, :post) }
  before do
    stub_omniauth

    stub_api_v2_resource(access_request, include: "requester,requester.organisations")
    stub_api_v2_resource_collection([access_request], include: "requester")
    submitted_access_request
  end

  describe "page header" do
    let(:list_access_requests_page) { PageObjects::Page::Organisations::ListAccessRequestsPage.new }

    let(:organisation) { build(:organisation) }
    let(:access_request) do
      build(:access_request,
            requester: user,
            requester_email: "v.vincent@pauli.edu",
            first_name: "Howard",
            last_name: "Kyoma",
            email_address: "h.kyoma@pauli.edu",
            reason: "Manual creation by user support agent")
    end

    context "user is admin" do
      let(:user) { build(:user, admin: true, organisations: [organisation]) }
      before do
        stub_omniauth(user: user)
      end

      it "links to the access requests page" do
        stub_api_v2_resource(current_recruitment_cycle)
        stub_api_v2_resource(provider, include: "courses.accrediting_provider")
        stub_api_v2_resource_collection([access_request], include: "requester")
        stub_api_v2_resource_collection([access_request])

        visit provider_courses_path(provider.provider_code)
        organisations_page.access_requests_link.click
        expect(list_access_requests_page).to be_displayed
      end
    end

    context "user is not admin" do
      let(:user) { build(:user, admin: false, organisations: [organisation]) }
      before do
        stub_omniauth(user: user)
      end

      it "does not link to the access requests page" do
        stub_api_v2_resource(current_recruitment_cycle)
        stub_api_v2_resource(provider, include: "courses.accrediting_provider")
        stub_api_v2_resource_collection([access_request], include: "requester")

        visit provider_courses_path(provider.provider_code)
        expect(organisations_page).to have_no_access_requests_link
      end
    end
  end

  describe "admin access request creation page" do
    let(:access_request) do
      build(:access_request,
            requester: user,
            requester_email: "v.vincent@pauli.edu",
            first_name: "Howard",
            last_name: "Kyoma",
            email_address: "h.kyoma@pauli.edu",
            reason: "Manual creation by user support agent")
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
      visit access_requests_path
      list_access_requests_page.create_access_request.click
      expect(new_access_request_page).to be_displayed

      new_access_request_page.requester_email.set("v.vincent@pauli.edu")
      new_access_request_page.email_address.set("h.kyoma@pauli.edu")
      new_access_request_page.first_name.set("Howard")
      new_access_request_page.last_name.set("Kyoma")
      new_access_request_page.preview.click
      expect(confirm_access_requests_page).to be_displayed
      confirm_access_requests_page.approve.click
      expect(access_request_submission_stub).to have_been_requested
    end
  end

  describe "index page" do
    let(:access_request) do
      build(:access_request,
            requester: user,
            request_date_utc: Date.new(2019, 11, 11),
            first_name: "Allen",
            last_name: "Swartz",
            email_address: "aswartz@mymail.co",
            organisation: "Aleph Null Academy")
    end

    it "lists all access requests" do
      visit access_requests_path
      expect(list_access_requests_page.access_requests.count).to eq(1)
      expect(list_access_requests_page.access_requests.first.request_date).to have_content("November 11, 2019")
      expect(list_access_requests_page.access_requests.first.recipient).to have_content("Allen Swartz <aswartz@mymail.co>")
      expect(list_access_requests_page.access_requests.first.organisation).to have_content("Aleph Null Academy")
    end

    it "can approve a request" do
      visit access_requests_path
      list_access_requests_page.access_requests.first.approve.click
      expect(confirm_access_requests_page).to be_displayed
      confirm_access_requests_page.approve.click
      expect(submitted_access_request).to have_been_requested
    end
  end

  describe "inform publisher page" do
    let(:access_request) do
      build(:access_request,
            requester: user,
            request_date_utc: Date.new(2019, 11, 11),
            first_name: "Allen",
            last_name: "Swartz",
            email_address: "aswartz@mymail.co",
            organisation: "Aleph Null Academy")
    end

    it "displays the inform publisher page when a request is approved" do
      visit access_requests_path
      list_access_requests_page.access_requests.first.approve.click
      confirm_access_requests_page.approve.click
      expect(inform_publisher_page).to be_displayed
    end

    it "links to the correct pages" do
      visit access_requests_path
      list_access_requests_page.access_requests.first.approve.click
      confirm_access_requests_page.approve.click
      expect(inform_publisher_page.dfe_signin_search_link[:href]).to eq("https://support.signin.education.gov.uk/users?criteria=aswartz@mymail.co")
      expect(inform_publisher_page.notify_service_link[:href]).to eq("https://www.notifications.service.gov.uk/services/022acc23-c40a-4077-bbd6-fc98b2155534")
      expect(inform_publisher_page.registered_user_link[:href]).to eq("https://www.notifications.service.gov.uk/services/022acc23-c40a-4077-bbd6-fc98b2155534/templates/4da327dd-907a-4619-abe6-45f348bb2fa3")
      expect(inform_publisher_page.unregistered_user_link[:href]).to eq("https://www.notifications.service.gov.uk/services/022acc23-c40a-4077-bbd6-fc98b2155534/templates/9ecac443-8cfd-49ac-ac59-e7ffa0ab6278")
      inform_publisher_page.done.click
      expect(list_access_requests_page).to be_displayed
    end
  end
end
