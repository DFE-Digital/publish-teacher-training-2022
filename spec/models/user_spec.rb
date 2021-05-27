require "rails_helper"

describe User, type: :model do
  let(:seen_accredited_body_features_user) { build(:user, :seen_accredited_body_new_features, associated_with_accredited_body: true) }
  let!(:update_request) { stub_request(:post, "#{Settings.teacher_training_api.base_url}/api/v2/users") }

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
