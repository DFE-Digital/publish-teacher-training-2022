require "rails_helper"

describe CourseDecorator do
  let(:current_recruitment_cycle) { build :recruitment_cycle }
  let(:next_recruitment_cycle) { build :recruitment_cycle, :next_cycle }
  let(:provider) { build(:provider, accredited_body?: false) }
  let(:course) {
    build :course,
          course_code: "A1",
          name: "Mathematics",
          qualification: "pgce_with_qts",
          study_mode: "full_time",
          start_date: Time.zone.local(2019),
          site_statuses: [site_status],
          provider: provider,
          accrediting_provider: provider,
          course_length: "OneYear",
          open_for_applications?: true,
          last_published_at: "2019-03-05T14:42:34Z",
          recruitment_cycle: current_recruitment_cycle
  }
  let(:site) { build(:site) }
  let(:site_status) do
    build(:site_status, :full_time_and_part_time, site: site)
  end

  let(:course_response) {
    course.to_jsonapi(
      include: %i[sites provider accrediting_provider recruitment_cycle],
    )
  }

  let(:decorated_course) { course.decorate }

  it "returns the course name and code in brackets" do
    expect(decorated_course.name_and_code).to eq("Mathematics (A1)")
  end

  it "returns a list of subjects in alphabetical order" do
    expect(decorated_course.sorted_subjects).to eq("English<br>English with Primary")
  end

  it "returns if applications are open or closed" do
    expect(decorated_course.open_or_closed_for_applications).to eq("Open")
  end

  it "returns if course is an apprenticeship" do
    expect(decorated_course.apprenticeship?).to eq("No")
  end

  it "returns if course is SEND?" do
    expect(decorated_course.is_send?).to eq("No")
  end

  it "returns course length" do
    expect(decorated_course.length).to eq("1 year")
  end

  context "recruitment cycles" do
    before do
      allow(Settings).to receive(:current_cycle).and_return(2019)
    end

    context "for a course in the current cycle" do
      let(:course) {
        build(:course, recruitment_cycle: current_recruitment_cycle)
      }

      it "knows which cycle it’s in" do
        expect(decorated_course.next_cycle?).to eq(false)
        expect(decorated_course.current_cycle?).to eq(true)
      end
    end

    context "for a course in the next cycle" do
      let(:course) {
        build(:course, recruitment_cycle: next_recruitment_cycle)
      }

      it "knows which cycle it’s in" do
        expect(decorated_course.next_cycle?).to eq(true)
        expect(decorated_course.current_cycle?).to eq(false)
      end
    end
  end

  context "status tag" do
    let(:status_tag) { course.decorate.status_tag }

    context "A non running course" do
      let(:course) { build(:course, ucas_status: "not_running") }

      it "Returns phase tag withdrawn" do
        expect(status_tag).to include("phase-tag--withdrawn")
      end

      it "Returns text withdrawn" do
        expect(status_tag).to include("Withdrawn")
      end
    end

    context "An empty course" do
      let(:course) { build(:course, content_status: "empty") }

      it "Returns phase tag published" do
        expect(status_tag).to include("phase-tag--no-content")
      end

      it "Returns text empty" do
        expect(status_tag).to include("Empty")
      end
    end

    context "A draft course" do
      let(:course) { build(:course, content_status: "draft") }

      it "Returns phase tag published" do
        expect(status_tag).to include("phase-tag--draft")
      end

      it "Returns text draft" do
        expect(status_tag).to include("Draft")
      end
    end

    context "A published with unpublished changes course" do
      let(:course) { build(:course, content_status: "published_with_unpublished_changes") }

      it "Returns phase tag published" do
        expect(status_tag).to include("phase-tag--published")
      end

      it "Returns text published*" do
        expect(status_tag).to include("Published&nbsp;*")
      end

      it "Returns unpublished status hint" do
        expect(status_tag).to include("*&nbsp;Unpublished&nbsp;changes")
      end
    end

    context "A rolled over course" do
      let(:course) { build(:course, content_status: "rolled_over") }

      it "Returns phase tag no content" do
        expect(status_tag).to include("phase-tag--no-content")
      end

      it "Returns text rolled over" do
        expect(status_tag).to include("Rolled over")
      end
    end

    context "A withdrawn course" do
      let(:course) { build(:course, content_status: "withdrawn") }

      it "Returns phase tag withdrawn" do
        expect(status_tag).to include("phase-tag--withdrawn")
      end

      it "Returns text withdrawn" do
        expect(status_tag).to include("Withdrawn")
      end
    end
  end
end
