require "rails_helper"

describe ProviderReferencesForm do
  let(:params) { {} }
  let(:provider) { build(:provider, provider_type: provider_type, urn: nil) }
  subject { described_class.new(provider, params: params) }

  describe "validations and save()" do
    before { subject.valid? }

    context "non-lead school" do
      let(:provider_type) { "scitt" }

      context "UKPRN is less than 8 characters" do
        let(:params) { { "ukprn" => "1234" } }

        it "raises an error for the ukprn attribute" do
          expect(subject.errors[:ukprn]).to eq(["UKPRN must be 8 numbers"])
        end
      end

      context "valid UKPRN" do
        let(:params) { { "ukprn" => "12345678" } }

        it "produces no validation error" do
          expect(subject).to be_valid
        end

        it "updates the ukprn attributes only" do
          expect(provider).to receive(:update).with(params)
          subject.save
        end
      end
    end

    context "lead school" do
      let(:provider_type) { "lead_school" }

      context "URN is less than 6 characters" do
        let(:params) { { "ukprn" => "12345678", "urn" => "1234" } }

        it "raises an error for the urn attribute" do
          expect(subject.errors[:urn]).to eq(["URN must be 5 or 6 numbers"])
        end
      end

      context "URN is valid" do
        let(:params) { { "ukprn" => "12345678", "urn" => "12345" } }

        it "produces no validation error" do
          expect(subject).to be_valid
        end

        it "updates the ukprn and urn attributes" do
          expect(provider).to receive(:update).with(params)
          subject.save
        end
      end
    end
  end
end
