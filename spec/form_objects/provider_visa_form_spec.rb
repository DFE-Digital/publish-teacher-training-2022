require "rails_helper"

RSpec.describe ProviderVisaForm do
  describe "validations" do
    context "when no skilled worker visa answer selected" do
      it "validation error is triggered" do
        subject.valid?
        expect(subject.errors[:can_sponsor_skilled_worker_visa]).to be_present
      end
    end

    context "when no student visa answer selected" do
      it "validation error is triggered" do
        subject.valid?
        expect(subject.errors[:can_sponsor_student_visa]).to be_present
      end
    end

    context "when all answers are given" do
      subject do
        described_class.new(
          can_sponsor_skilled_worker_visa: true,
          can_sponsor_student_visa: false,
        )
      end

      it "is valid" do
        expect(subject.valid?).to be true
      end
    end
  end
end
