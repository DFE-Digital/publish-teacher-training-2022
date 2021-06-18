require "rails_helper"

RSpec.describe Courses::Degrees::GradeForm do
  describe "validations" do
    it "is invalid if degree grade is nil" do
      form = described_class.new(grade: nil)
      expect(form.valid?).to be_falsey
    end
  end

  describe "save" do
    let(:course) { instance_double(Course) }

    it "updates the degree_grade" do
      allow(course).to receive(:update).and_return(true)

      form = described_class.new(grade: "two_two")

      expect(form.save(course)).to eq true
    end
  end

  describe "#build_from_course" do
    it "builds a new DegreeGradeForm and sets degree_grade" do
      course = build(:course, grade: "two_one")
      form = described_class.build_from_course(course)

      expect(form.grade).to eq "two_one"
    end
  end
end
