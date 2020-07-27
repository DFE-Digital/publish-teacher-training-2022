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
      let(:rolled_over_user) { build(:user, :rolled_over) }

      before do
        allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(true)
      end

      it "changes state from 'transitioned' to 'accepted_rollover_2021'" do
        transitioned_user.accept_rollover_screen!

        expect(transitioned_user.accepted_rollover_2021?).to be true
        expect(update_request).to have_been_made
      end

      it "changes state from 'rolled_over' to 'accepted_rollover_2021'" do
        rolled_over_user.accept_rollover_screen!

        expect(rolled_over_user.accepted_rollover_2021?).to be true
        expect(update_request).to have_been_made
      end
    end

    context "rollover is not allowed" do
      let(:rolled_over_user) { create(:user, :rolled_over) }

      before do
        allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
      end

      it "raises and error when trying to change state from 'transitioned' to 'rolled_over'" do
        expect { rolled_over_user.accept_rollover_screen! }.to_not raise_error
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

  describe "#accepted_terms?" do
    context "when they have accepted terms" do
      subject { build(:user) }

      it "returns true" do
        expect(subject.accepted_terms?).to be_truthy
      end
    end

    context "when they have not accepted terms" do
      subject { build(:user, :inactive) }

      it "returns false" do
        expect(subject.accepted_terms?).to be_falsey
      end
    end
  end
end
