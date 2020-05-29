require "rails_helper"

describe ProvidersView do
  subject { described_class.new(providers: providers) }

  describe "show_notifications_link?" do
    context "one accredited body" do
      let(:providers) { [build(:provider, :accredited_body)] }
      it "returns false" do
        expect(subject.show_notifications_link?).to eq(false)
      end
    end

    context "more than one accredited body" do
      let(:providers) do
        [
          build(:provider, :accredited_body),
          build(:provider, :accredited_body),
        ]
      end
      it "returns true" do
        expect(subject.show_notifications_link?).to eq(true)
      end
    end
  end
end
