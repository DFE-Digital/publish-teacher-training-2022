require "rails_helper"

RSpec.describe Courses::Degrees::StartForm do
  describe "validations" do
    it "is invalid if no value is selected for degree_grade_required" do
      form = described_class.new(degree_grade_required: nil)
      expect(form.valid?).to be_falsey
    end
  end

  describe "#save" do
    let(:course) { instance_double(Course) }

    it "returns false if degree_grade_required is true" do
      form = described_class.new(degree_grade_required: true)
      expect(form.save(course)).to eq false
    end

    it "returns false if invalid" do
      form = described_class.new(degree_grade_required: nil)
      expect(form.save(course)).to eq false
    end

    it "updates the degree_subject to `not_required` if false" do
      allow(course).to receive(:update).and_return(true)

      form = described_class.new(degree_grade_required: false)

      expect(form.save(course)).to eq true
    end
  end

  describe "#set_attributes" do
    context "when the degree grade is not_required" do
      it "sets degree_grade_required to false" do
        course = build(:course, degree_grade: "not_required")
        form = described_class.new
        form.set_attributes(course)

        expect(form.degree_grade_required).to eq false
      end
    end

    context "when the degree grade is any other enum value" do
      it "sets degree_grade_required to true" do
        course = build(:course, degree_grade: "two_one")
        form = described_class.new
        form.set_attributes(course)

        expect(form.degree_grade_required).to eq true
      end
    end

    context "when the degree grade nil" do
      it "sets degree_grade_required to nil" do
        course = build(:course, degree_grade: nil)
        form = described_class.new
        form.set_attributes(course)

        expect(form.degree_grade_required).to eq nil
      end
    end
  end
end
