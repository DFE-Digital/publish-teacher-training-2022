require "rails_helper"

describe UcasContactView do
  let(:provider) { build(:provider) }

  subject do
    described_class.new(provider: provider)
  end

  describe "CONTACT_TYPES" do
    let(:expected_contacts) { %i[admin fraud finance web_link utt] }

    it "returns all UCAS contact types" do
      expect(described_class::CONTACT_TYPES).to contain_exactly(*expected_contacts)
    end

    describe "#contact_types" do
      it "returns CONTACT_TYPES" do
        expect(subject.contact_types).to contain_exactly(*expected_contacts)
      end
    end
  end

  describe "#provider" do
    it "returns the provider" do
      expect(subject.provider).to eq(provider)
    end
  end

  describe "#contact" do
    let(:admin_contact) { build(:contact, :admin) }
    let(:contacts) do
      [
        build(:contact, :utt),
        admin_contact,
        build(:contact, :fraud),
      ]
    end

    before do
      allow(provider).to receive(:contacts).and_return(contacts)
    end

    it "returns the requested contact" do
      expect(subject.contact(:admin)).to eq(admin_contact)
    end
  end

  describe "#provider_code" do
    let(:provider) { build(:provider, provider_code: "1HO") }

    it "returns the provider's code" do
      expect(subject.provider_code).to eq("1HO")
    end
  end

  describe "#gt12_contact" do
    let(:provider) { build(:provider, gt12_contact: "test@example.com") }

    it "returns the gt12_contact" do
      expect(subject.gt12_contact).to eq("test@example.com")
    end
  end

  describe "#send_application_alerts" do
    let(:provider) { build(:provider, send_application_alerts: true) }

    it "returns send_application_alerts" do
      expect(subject.send_application_alerts).to eq(true)
    end
  end

  describe "#application_alert_contact" do
    let(:provider) { build(:provider, application_alert_contact: "test@example.com") }

    it "returns the application_alert_contact" do
      expect(subject.application_alert_contact).to eq("test@example.com")
    end
  end
end
