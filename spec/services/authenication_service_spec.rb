require "rails_helper"

describe AuthenticationService do
  context "defaults" do
    it { expect(subject.mode).to eql("dfe_signin") }

    it { expect(subject.persona?).to eq false }

    it { expect(subject.dfe_signin?).to eq true }

    it { expect(subject.magic?).to eq false }

    it { expect(subject.basic_auth?).to eq false }
  end

  context "Settings.authentication.mode " do
    let(:basic_auth_disabled_value) { false }

    around(:each) do |example|
      old_mode_value = Settings.authentication.mode
      old_basic_auth_disabled_value = Settings.authentication.basic_auth.disabled

      Settings.authentication.mode = mode_value
      Settings.authentication.basic_auth.disabled = basic_auth_disabled_value

      example.run

      Settings.authentication.mode = old_mode_value
      Settings.authentication.basic_auth.disabled = old_basic_auth_disabled_value
    end

    context "is persona" do
      let(:mode_value) { "persona" }

      it { expect(subject.mode).to eql("persona") }

      it { expect(subject.persona?).to eq true }

      it { expect(subject.dfe_signin?).to eq false }

      it { expect(subject.magic?).to eq false }

      it { expect(subject.basic_auth?).to eq true }

      context "Settings.authentication.basic_auth.disabled is true" do
        let(:basic_auth_disabled_value) { true }
        it { expect(subject.dfe_signin?).to eq false }
      end
    end

    context "is dfe_signin" do
      let(:mode_value) { "dfe_signin" }

      it { expect(subject.mode).to eql("dfe_signin") }

      it { expect(subject.persona?).to eq false }

      it { expect(subject.dfe_signin?).to eq true }

      it { expect(subject.magic?).to eq false }

      it { expect(subject.basic_auth?).to eq false }

      context "Settings.authentication.basic_auth.disabled is true" do
        let(:basic_auth_disabled_value) { true }
        it { expect(subject.basic_auth?).to eq false }
      end
    end

    context "is magic" do
      let(:mode_value) { "magic" }

      it { expect(subject.mode).to eql("magic") }

      it { expect(subject.persona?).to eq false }

      it { expect(subject.dfe_signin?).to eq false }

      it { expect(subject.magic?).to eq true }

      it { expect(subject.basic_auth?).to eq false }

      context "Settings.authentication.basic_auth.disabled is true" do
        let(:basic_auth_disabled_value) { true }
        it { expect(subject.basic_auth?).to eq false }
      end
    end

    context "is gibberish" do
      let(:mode_value) { "gibberish" }

      it { expect(subject.mode).to eql("dfe_signin") }

      it { expect(subject.persona?).to eq false }

      it { expect(subject.dfe_signin?).to eq true }

      it { expect(subject.magic?).to eq false }

      it { expect(subject.basic_auth?).to eq false }

      context "Settings.authentication.basic_auth.disabled is true" do
        let(:basic_auth_disabled_value) { true }
        it { expect(subject.basic_auth?).to eq false }
      end
    end
  end
end
