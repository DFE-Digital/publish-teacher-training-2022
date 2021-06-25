require "rails_helper"

RSpec.describe Courses::Degrees::SubjectRequirementsForm do
  describe "validations" do
    it "is invalid if no value is selected for `additional_degree_subject_requirements`" do
      form = described_class.new(additional_degree_subject_requirements: nil)
      expect(form.valid?).to be_falsey
    end

    it "is invalid if `additional_degree_subject_requirements` is true and no `degree_subject_requirements` are provided" do
      form = described_class.new(
        additional_degree_subject_requirements: true,
        degree_subject_requirements: nil,
      )
      expect(form.valid?).to be_falsey
    end
  end

  describe "save" do
    let(:course) { instance_double(Course) }

    it "returns false if invalid" do
      form = described_class.new

      expect(form.save(course)).to eq false
    end

    it "updates the course if valid" do
      allow(course).to receive(:update).with({ additional_degree_subject_requirements: true, degree_subject_requirements: "Maths A level" }).and_return(true)

      form = described_class.new(
        additional_degree_subject_requirements: true,
        degree_subject_requirements: "Maths A level",
      )

      expect(form.save(course)).to eq true
    end
  end

  describe "#build_from_course" do
    it "builds a new DegreeSubjectRequirementsForm and sets the attrs based on the course" do
      course = build(
        :course,
        additional_degree_subject_requirements: true,
        degree_subject_requirements: "Maths A level.",
      )
      form = described_class.build_from_course(course)

      expect(form.additional_degree_subject_requirements).to eq true
      expect(form.degree_subject_requirements).to eq "Maths A level."
    end
  end
end
