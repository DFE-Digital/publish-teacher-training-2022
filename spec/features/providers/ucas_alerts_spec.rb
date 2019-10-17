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
    expect(page.alerts_enabled_fields).to have_all
    expect(page.alerts_enabled_fields).to have_none
    expect(page.alerts_enabled_fields.all).not_to be_checked
    expect(page.alerts_enabled_fields.none).not_to be_checked
    set_alerts_request_stub_expectation("none")
    page.alerts_enabled_fields.none.click
    click_on "Save"
    expect(org_ucas_contacts_page).to be_displayed
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
      set_alerts_request_stub_expectation("all")
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
      set_alerts_request_stub_expectation("none")
      page.alerts_enabled_fields.none.click
      click_on "Save"
      expect(org_ucas_contacts_page).to be_displayed
    end
  end

  scenario "can navigate back to ucas contacts page" do
    click_on "Back"
    expect(org_ucas_contacts_page).to be_displayed
  end

private

  def set_alerts_request_stub_expectation(expected_setting)
    post_stub = stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      provider.to_jsonapi,
      :patch, 200
    )
    post_stub.with do |request|
      body = JSON.parse(request.body)
      expect(body["data"]["attributes"]["send_application_alerts"]).to eq(expected_setting)
    end
  end
end
