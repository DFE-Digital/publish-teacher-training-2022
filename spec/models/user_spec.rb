require "rails_helper"

describe User, type: :model do
  let(:seen_accredited_body_features_user) { build(:user, :seen_accredited_body_new_features, associated_with_accredited_body: true) }
  let!(:update_request) { stub_request(:post, "#{Settings.manage_backend.base_url}/api/v2/users") }

  describe "initial state" do
    let(:user) { build(:user, state: nil) }

    it "sets state to 'new'" do
      expect(user.aasm.current_state).to eq(:new)
    end
  end

  describe "transition state event" do
    context "user has state 'new'" do
      let(:new_user) { build(:user, :new) }

      it "changes state from 'new' to 'transitioned'" do
        new_user.accept_transition_screen!

        expect(new_user.transitioned?).to be true
        expect(update_request).to have_been_made
      end
    end
  end

  describe "rolled_over state event" do
    context "rollover is allowed" do
      let(:transitioned_user) { build(:user, :transitioned) }

      before do
        allow(Settings).to receive(:rollover).and_return(true)
      end

      it "changes state from 'transitioned' to 'rolled_over'" do
        transitioned_user.accept_rollover_screen!

        expect(transitioned_user.rolled_over?).to be true
        expect(update_request).to have_been_made
      end
    end

    context "rollover is not allowed" do
      let(:rolled_over_user) { create(:user, :rolled_over) }

      before do
        allow(Settings).to receive(:rollover).and_return(false)
      end

      it "raises and error when trying to change state from 'transitioned' to 'rolled_over'" do
        expect { rolled_over_user.accept_rollover_screen! }.to raise_error(AASM::InvalidTransition)
        expect(update_request).not_to have_been_made
      end
    end
  end

  describe "notifications_configured state event" do
    context "user is associated with an accredited body and not subscribed to notifications" do
      let(:rolled_over_user) do
        build(
          :user,
          :rolled_over,
          associated_with_accredited_body: true,
          notifications_configured: false,
        )
      end

      it "changes state from 'rolled_over' to 'subscribed_to_notifications'" do
        rolled_over_user.accept_notifications_screen!

        expect(rolled_over_user.notifications_configured?).to be true
        expect(update_request).to have_been_made
      end
    end

    context "user is not associated with an accredited body and subscribed to notifications" do
      let(:rolled_over_user) { build(:user, :rolled_over, associated_with_accredited_body: false, notifications_configured: true) }

      it "raises an error when trying to change state from 'rolled_over' to 'subscribed_to_notifications'" do
        expect { rolled_over_user.accept_notifications_screen! }.to raise_error(AASM::InvalidTransition)
        expect(update_request).not_to have_been_made
      end
    end

    context "user is associated with an accredited body and subscribed to notifications" do
      let(:rolled_over_user) { build(:user, :rolled_over, associated_with_accredited_body: true, notifications_configured: true) }

      it "raises an error when trying to change state from 'rolled_over' to 'subscribed_to_notifications'" do
        expect { rolled_over_user.accept_notifications_screen! }.to raise_error(AASM::InvalidTransition)
        expect(update_request).not_to have_been_made
      end
    end
  end

  describe "#next_state" do
    let(:new_user) { create(:user, :new) }

    it "returns the next state" do
      expect(new_user.next_state).to eq(:transitioned)
    end
  end
end
