require "rails_helper"

describe Contact do
  describe "#admin?" do
    subject { described_class.new(type: type).admin? }

    context "type is 'admin'" do
      let(:type) { "admin" }
      it { is_expected.to be(true) }
    end

    context "type isn't admin" do
      let(:type) { "utt" }
      it { is_expected.to be(false) }
    end
  end
end
