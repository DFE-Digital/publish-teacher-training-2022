require "rails_helper"

feature "View provider UCAS contact", type: :feature do
  let(:org_ucas_contacts_page) { PageObjects::Page::Organisations::UcasContacts.new }
  let(:provider) do
    build :provider,
          provider_code: "A0"
  end

  before do
    stub_omniauth

    stub_api_v2_resource(provider)
  end

  scenario "viewing organisation UCAS contacts page" do
    visit provider_ucas_contacts_path(provider.provider_code)

    expect(current_path).to eq provider_ucas_contacts_path(provider.provider_code)

    expect(org_ucas_contacts_page.title).to have_content("UCAS contacts")

    expect(org_ucas_contacts_page.utt_contact).to have_content(provider.utt_contact[:name])
    expect(org_ucas_contacts_page.web_link_contact).to have_content(provider.web_link_contact[:name])
    expect(org_ucas_contacts_page.finance_contact).to have_content(provider.finance_contact[:name])
    expect(org_ucas_contacts_page.fraud_contact).to have_content(provider.fraud_contact[:name])
    expect(org_ucas_contacts_page.admin_contact).to have_content(provider.admin_contact[:name])
    expect(org_ucas_contacts_page.gt12_contact).to have_content(provider.gt12_contact)
    expect(org_ucas_contacts_page.application_alert_contact).to have_content(provider.application_alert_contact)
  end
end
