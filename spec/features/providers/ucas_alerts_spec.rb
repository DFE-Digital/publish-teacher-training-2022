require "rails_helper"

feature "Edit UCAS email alerts", type: :feature do
  let(:page) { PageObjects::Page::Organisations::UcasContactsAlerts.new }
  let(:org_ucas_contacts_page) { PageObjects::Page::Organisations::UcasContacts.new }
  let(:provider) { build(:provider, send_application_alerts: nil) }
  let(:current_recruitment_cycle) { build :recruitment_cycle }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    visit alerts_provider_ucas_contacts_path(provider.provider_code)
  end

  scenario "selecting and saving an option" do
    expect(current_path).to eq alerts_provider_ucas_contacts_path(provider.provider_code)
    expect(page.title).to have_content("Email alerts for new applications")
    expect(page.main_heading).to have_content("Email alerts for new applications")
    expect(page).to have_alerts_enabled_fields
    expect(page.alerts_enabled_fields.all).not_to be_checked
    expect(page.alerts_enabled_fields.none).to be_checked
    set_alerts_request_stub_expectation do |request_attributes|
      expect(request_attributes["send_application_alerts"]).to eq("all")
    end
    page.alerts_enabled_fields.all.click
    click_on "Save"
    expect(org_ucas_contacts_page).to be_displayed
    expect(org_ucas_contacts_page.flash).to have_content("Your changes have been saved")
  end

  scenario "can cancel changes" do
    expect(current_path).to eq alerts_provider_ucas_contacts_path(provider.provider_code)
    click_on "Cancel changes"
    expect(org_ucas_contacts_page).to be_displayed
  end

  context "email alerts: none" do
    let(:provider) { build(:provider, send_application_alerts: "none") }

    scenario "selecting and saving an option" do
      expect(page.alerts_enabled_fields.all).not_to be_checked
      expect(page.alerts_enabled_fields.none).to be_checked
      set_alerts_request_stub_expectation do |request_attributes|
        expect(request_attributes["send_application_alerts"]).to eq("all")
      end
      page.alerts_enabled_fields.all.click
      click_on "Save"
      expect(org_ucas_contacts_page).to be_displayed
    end
  end

  context "email alerts: all" do
    let(:provider) { build(:provider, send_application_alerts: "all") }

    scenario "selecting and saving an option" do
      expect(page.alerts_enabled_fields.all).to be_checked
      expect(page.alerts_enabled_fields.none).not_to be_checked
      set_alerts_request_stub_expectation do |request_attributes|
        expect(request_attributes["send_application_alerts"]).to eq("none")
      end
      page.alerts_enabled_fields.none.click
      click_on "Save"
      expect(org_ucas_contacts_page).to be_displayed
    end
  end

  scenario "can navigate back to ucas contacts page" do
    click_on "Back"
    expect(org_ucas_contacts_page).to be_displayed
  end

  scenario "changing the email address" do
    page.application_alert_contact.set "bob@example.org"
    page.share_with_ucas_permission.click
    set_alerts_request_stub_expectation do |request_attributes|
      expect(request_attributes["send_application_alerts"]).to eq("none")
      expect(request_attributes["application_alert_contact"]).to eq("bob@example.org")
    end
    click_on "Save"
    expect(org_ucas_contacts_page).to be_displayed
    expect(org_ucas_contacts_page.flash).to have_content("Your changes have been saved")
  end

  scenario "not ticking permissions box for sharing with ucas" do
    page.application_alert_contact.set "bob@example.org"
    click_on "Save"
    expect(page).to be_displayed(provider_code: provider.provider_code)
    expect(page.error_summary).to have_content("Please give permission to share this email with UCAS")
  end

private

  def set_alerts_request_stub_expectation(&attribute_validator)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      provider.to_jsonapi,
      :patch,
      200,
    ) do |request_body_json|
      request_attributes = request_body_json["data"]["attributes"]
      attribute_validator.call(request_attributes)
    end
  end
end
