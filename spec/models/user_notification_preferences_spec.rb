require "rails_helper"

describe UserNotificationPreferences do
  describe "#explictly_enabled" do
    subject { UserNotificationPreferences.new(enabled: enabled, updated_at: updated_at).explicitly_enabled }

    context "enabled == true" do
      let(:enabled) { true }

      context "updated_at is present" do
        let(:updated_at) { Time.zone.now.to_s }

        it { is_expected.to eq(true) }
      end
    end

    context "enabled == false" do
      let(:enabled) { false }

      context "updated_at is empty" do
        let(:updated_at) { nil }

        it { is_expected.to be_nil }
      end

      context "updated_at is present" do
        let(:updated_at) { Time.zone.now.to_s }

        it { is_expected.to eq(false) }
      end
    end
  end
end
