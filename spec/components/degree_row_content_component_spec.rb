require "rails_helper"

RSpec.describe DegreeRowContentComponent, type: :component do
  context "when the degree section is incomplete" do
    it "renders a link to the degree section" do
      recruitment_cycle = build(:recruitment_cycle)
      provider = build(:provider, recruitment_cycle: recruitment_cycle)
      course = build(
        :course,
        provider: provider,
        degree_grade: nil,
        degree_subject_requirement: nil,
      )

      render_inline(described_class.new(course: course))

      expect(page).to have_link(
        "Enter degree requirements",
        href: Rails.application.routes.url_helpers.degrees_start_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          course.course_code,
        ),
      )
    end
  end

  context "when the degree section is complete" do
    context "when degree type is 'two_one'" do
      it "renders '2:1 or above, or equivalent'" do
        course = build(
          :course,
          degree_grade: "two_one",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("2:1 or above, or equivalent")
      end
    end

    context "when degree type is 'two_two'" do
      it "renders '2:2 or above, or equivalent'" do
        course = build(
          :course,
          degree_grade: "two_two",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("2:2 or above, or equivalent")
      end
    end

    context "when degree type is 'two_one'" do
      it "renders '2:1 or above, or equivalent'" do
        course = build(
          :course,
          degree_grade: "two_one",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("2:1 or above, or equivalent")
      end
    end

    context "when degree type is 'third_class'" do
      it "renders 'Third class degree or above, or equivalent'" do
        course = build(
          :course,
          degree_grade: "third_class",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Third class degree or above, or equivalent")
      end
    end

    context "when degree type is 'not_required'" do
      it "renders 'Third class degree or above, or equivalent'" do
        course = build(
          :course,
          degree_grade: "not_required",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("An undergraduate degree, or equivalent")
      end
    end

    context "when degree_subject_requirements and a degree grade are present" do
      it "renders the correct content for both attributes" do
        course = build(
          :course,
          degree_grade: "two_one",
          degree_subject_requirements: "Maths A level.",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("2:1 or above, or equivalent")
        expect(page).to have_content("Maths A level.")
      end
    end
  end
end
