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

  describe "#is_school_direct?" do
    context "is an accredited body" do
      let(:provider) { build(:provider, accredited_body?: true) }
      let(:course) { build(:course, :new, provider: provider) }

      it "is not a school direct" do
        expect(course.is_school_direct?).to eq(false)
      end
    end

    context "is further education" do
      let(:provider) { build(:provider, accredited_body?: false) }
      let(:course) { build(:course, :new, level: "further_education", provider: provider) }

      it "is not a school direct" do
        expect(course.is_school_direct?).to eq(false)
      end
    end

    context "is not an accredited body or further education" do
      let(:provider) { build(:provider, accredited_body?: false) }
      let(:course) { build(:course, :new, level: "primary", provider: provider) }

      it "is a school direct" do
        expect(course.is_school_direct?).to eq(true)
      end
    end
  end

  describe "#is_uni_or_scitt?" do
    context "is an accredited body" do
      let(:provider) { build(:provider, accredited_body?: true) }

      it "is a uni or SCITT" do
        expect(course.is_uni_or_scitt?).to eq(true)
      end
    end

    context "is not an accredited body" do
      let(:provider) { build(:provider, accredited_body?: false) }

      it "is not a uni or SCITT" do
        expect(course.is_uni_or_scitt?).to eq(false)
      end
    end
  end

  describe "#is_further_education?" do
    context "has the level further education" do
      let(:course) { build(:course, :new, level: "further_education", provider: provider) }

      it "is a further education course" do
        expect(course.is_further_education?).to eq(true)
      end
    end

    context "has the level primary" do
      let(:course) { build(:course, :new, level: "primary", provider: provider) }

      it "is not a further education course" do
        expect(course.is_further_education?).to eq(false)
      end
    end
  end

  describe "#travel_to_work_areas" do
    context "when there is a single travel to work area" do
      let(:site1) { build(:site, travel_to_work_area: "Brighton") }
      let(:course) { build(:course, sites: [site1]) }

      it "returns that site" do
        expect(course.travel_to_work_areas).to eq "Brighton"
      end
    end

    context "when there is a london borough and travel to work area" do
      let(:site1) { build(:site, london_borough: "Westminster", travel_to_work_area: "Test") }
      let(:course) { build(:course, sites: [site1]) }

      it "returns just the london borough" do
        expect(course.travel_to_work_areas).to eq "Westminster"
      end
    end

    context "when there are two  different travel sites" do
      let(:site1) { build(:site, london_borough: "Westminster") }
      let(:site2) { build(:site, travel_to_work_area: "Brighton") }
      let(:course) { build(:course, sites: [site1, site2]) }

      it "returns both sites with the correct format" do
        expect(course.travel_to_work_areas).to eq "Westminster and Brighton"
      end
    end

    context "when there is a mixture of more than two travel sites" do
      let(:site1) { build(:site, london_borough: "Westminster") }
      let(:site2) { build(:site, london_borough: "Southwark") }
      let(:site3) { build(:site, travel_to_work_area: "Brighton") }
      let(:course) { build(:course, sites: [site1, site2, site3]) }

      it "returns all sites in the correct format" do
        expect(course.travel_to_work_areas).to eq "Westminster, Southwark and Brighton"
      end
    end
  end

  describe "#provider_type" do
    it "returns the provider type" do
      expect(course.provider_type).to eq("lead_school")
    end
  end

  describe "degree_section_complete?" do
    it "returns true when 'degree_grade' is set" do
      course = build(
        :course,
        degree_grade: "two_one",
      )

      expect(course.degree_section_complete?).to eq true
    end

    it "return false when 'degree_grade' is nil" do
      course = build(
        :course,
        degree_grade: nil,
      )

      expect(course.degree_section_complete?).to eq false
    end
  end
end
