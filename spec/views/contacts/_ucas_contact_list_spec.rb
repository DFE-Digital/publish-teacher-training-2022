require "rails_helper"

describe "ucas_contact_list" do
  let(:ucas_contact_view) { instance_double(UcasContactView, provider_code: "1XO") }
  let(:contacts_page) { PageObjects::Page::Organisations::UcasContacts.new }

  before do
    allow(ucas_contact_view)
      .to receive(:contact)
      .and_return(nil)
  end

  def load_partial
    render partial: "ucas_contacts/ucas_contact_list", locals: { ucas_contact_view: ucas_contact_view }
    contacts_page.load(rendered)
  end

  context "provider has no contacts" do
    before { load_partial }

    it "renders five contacts rows" do
      expect(contacts_page).to have_contacts(count: 5)
    end
  end

  context "contact type is not present" do
    before { load_partial }

    it "renders 'Information unknown'" do
      expect(contacts_page.admin_contact.details).to have_content("Information unknown")
    end

    it "doesn't render a change link" do
      expect(contacts_page.admin_contact).to have_no_change_link
    end
  end

  context "contact type is present" do
    let(:admin_contact) { build(:contact, :admin, id: 1) }

    before do
      allow(ucas_contact_view)
        .to receive(:contact)
        .with(:admin)
        .and_return(admin_contact)

      load_partial
    end

    it "renders the contact details" do
      expect(contacts_page.admin_contact.details).to have_content(admin_contact.name)
    end

    it "renders a change link" do
      expect(contacts_page.admin_contact).to have_change_link
    end
  end
end
