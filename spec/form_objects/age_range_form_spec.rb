require "rails_helper"

RSpec.describe AgeRangeForm do
  let(:preset_ranges) { %w[11_to_16 11_to_18 14_to_19] }

  describe "#new" do
    context "when a custom age_range" do
      subject { described_class.new(age_range_in_years: "10_to_20", presets: preset_ranges) }

      it "populates from and to and sets as other" do
        expect(subject.age_range_in_years).to eql("other")
        expect(subject.course_age_range_in_years_other_from).to eql(10)
        expect(subject.course_age_range_in_years_other_to).to eql(20)
      end
    end

    context "when a preset age_range" do
      subject { described_class.new(age_range_in_years: "11_to_16", presets: preset_ranges) }

      it "uses preset value" do
        expect(subject.age_range_in_years).to eql("11_to_16")
        expect(subject.course_age_range_in_years_other_from).to be_nil
        expect(subject.course_age_range_in_years_other_to).to be_nil
      end
    end
  end

  describe "validations" do
    context "when age_range_in_years not selected" do
      subject { described_class.new(age_range_in_years: nil) }

      it "is not valid" do
        expect(subject.valid?).to be_falsey
      end
    end

    context "when age_range_in_years is other" do
      context "and from years is not present" do
        subject do
          described_class.new(age_range_in_years: "other",
                              course_age_range_in_years_other_from: nil,
                              course_age_range_in_years_other_to: "10",
                              presets: preset_ranges)
        end

        it "is not valid" do
          expect(subject.valid?).to be_falsey
        end
      end

      context "and to years is not present" do
        subject do
          described_class.new(age_range_in_years: "other",
                              course_age_range_in_years_other_from: "10",
                              course_age_range_in_years_other_to: nil,
                              presets: preset_ranges)
        end

        it "is not valid" do
          expect(subject.valid?).to be_falsey
        end
      end
    end

    context "when from is bigger than to age" do
      subject do
        described_class.new(age_range_in_years: "other",
                            course_age_range_in_years_other_from: "11",
                            course_age_range_in_years_other_to: "10",
                            presets: preset_ranges)
      end

      it "is not valid" do
        expect(subject.valid?).to be_falsey
      end
    end

    context "when custom age range is under 4 years" do
      subject do
        described_class.new(age_range_in_years: "other",
                            course_age_range_in_years_other_from: "10",
                            course_age_range_in_years_other_to: "11",
                            presets: preset_ranges)
      end

      it "is not valid" do
        expect(subject.valid?).to be_falsey
      end
    end

    context "when from age is outside allowed range" do
      subject do
        described_class.new(age_range_in_years: "other",
                            course_age_range_in_years_other_from: "47",
                            course_age_range_in_years_other_to: "49",
                            presets: preset_ranges)
      end

      it "is not valid" do
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:course_age_range_in_years_other_from]).to include("From age must be between 0 and 46")
      end
    end

    context "when from age is outside allowed range" do
      subject do
        described_class.new(age_range_in_years: "other",
                            course_age_range_in_years_other_from: "10",
                            course_age_range_in_years_other_to: "51",
                            presets: preset_ranges)
      end

      it "is not valid" do
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:course_age_range_in_years_other_to]).to include("To age must be between 4 and 50")
      end
    end
  end
end
