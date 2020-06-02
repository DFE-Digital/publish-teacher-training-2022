require "rails_helper"

describe ProviderView do
  subject { described_class.new(provider: provider, providers: providers) }

  describe "show_notifications_link?" do
    context "provider is an accredited_body" do
      context "one accredited body" do
        let(:provider) { build(:provider, accredited_body?: true) }
        let(:providers) { [provider] }
        it "returns true" do
          expect(subject.show_notifications_link?).to eq(true)
        end
      end

      context "more than one accredited body" do
        let(:provider) { build(:provider, accredited_body?: true) }
        let(:providers) do
          [
            provider,
            build(:provider, accredited_body?: true),
          ]
        end
        it "returns false" do
          expect(subject.show_notifications_link?).to eq(false)
        end
      end
    end

    context "provider is not an accredited_body" do
      let(:provider) { build(:provider) }
      let(:providers) { [provider] }

      it "returns false" do
        expect(subject.show_notifications_link?).to eq(false)
      end
    end
  end
end
