require "rails_helper"

describe Course do
  let(:provider)          { build :provider }
  let(:course)            { build :course, :new, provider: provider }
  describe "#build_new" do
    let(:recruitment_cycle) { course.recruitment_cycle }
    let(:build_course_stub) { stub_api_v2_build_course }

    before do
      allow(Thread.current).to receive(:fetch).and_return("token")

      stub_omniauth
      build_course_stub
    end

    let(:fetched_new_course) do
      Course.build_new(
        recruitment_cycle_year: recruitment_cycle.year,
        provider_code: provider.provider_code,
      )
    end

    it "makes a request to the api" do
      fetched_new_course
      expect(build_course_stub).to have_been_requested
    end

    it "returns the result" do
      expect(fetched_new_course.id).to eq nil
      expect(fetched_new_course.type).to eq "courses"
    end
  end

  context "#is_withdrawn?" do
    context "With a withdrawn course" do
      let(:course) { build(:course, content_status: "withdrawn") }

      it "is withdrawn" do
        expect(course.is_withdrawn?).to eq(true)
      end
    end

    context "With a published course" do
      let(:course) { build(:course, content_status: "published") }

      it "is not withdrawn" do
        expect(course.is_withdrawn?).to eq(false)
      end
    end
  end

  context "#not_running?" do
    context "With a ucas status of new" do
      let(:course) { build(:course, ucas_status: "new") }

      it "is running" do
        expect(course.not_running?).to eq(false)
      end
    end

    context "With a ucas status of running" do
      let(:course) { build(:course, ucas_status: "running") }

      it "is running" do
        expect(course.not_running?).to eq(false)
      end
    end

    context "With a ucas status of not_running" do
      let(:course) { build(:course, ucas_status: "not_running") }

      it "is not running" do
        expect(course.not_running?).to eq(true)
      end
    end
  end

  context "#has_physical_education_subject?" do
    it "has a physical education subject" do
      course = build(:course, subjects: [build(:subject, subject_name: "Physical education")])
      expect(course.has_physical_education_subject?).to eq(true)
    end

    it "does not have a physical education subject" do
      course = build(:course, subjects: [build(:subject, subject_name: "Biology")])
      expect(course.has_physical_education_subject?).to eq(false)
    end
  end
end
