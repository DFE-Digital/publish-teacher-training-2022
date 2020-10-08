require "rails_helper"

describe "contacts/edit" do
  let(:contacts_edit_page) { PageObjects::Page::Organisations::UcasContactsEdit.new }

  let(:contact) { build(:contact, id: 1, type: type) }
  let(:provider) { build(:provider, provider_code: "1X0") }

  before do
    assign(:contact, contact)
    assign(:provider, provider)

    render
    contacts_edit_page.load(rendered)
  end

  context "contact is an admin" do
    let(:type) { "admin"  }

    it "renders the admin subheading" do
      expect(contacts_edit_page.admin_subheading.text).to eq("Request a change to your UCAS administrator")
    end

    it "renders the admin subtext" do
      expect(contacts_edit_page.admin_subtext.text).to eq("Changes can take up to 7 days to process.")
    end

    it "renders the submit button with 'Request changes'" do
      expect(contacts_edit_page.submit_button.value).to eq("Request changes")
    end
  end

  context "contact isn't an admin" do
    let(:type) { "utt" }

    it "doesn't render the admin subheading" do
      expect(contacts_edit_page.has_no_admin_subheading?).to be(true)
    end

    it "doesn't render the admin subtext" do
      expect(contacts_edit_page.has_no_admin_subtext?).to be(true)
    end

    it "renders the submit button with 'Save'" do
      expect(contacts_edit_page.submit_button.value).to eq("Save")
    end
  end
end
