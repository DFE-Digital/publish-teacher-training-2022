require "rails_helper"

RSpec.describe DegreePreviewComponent, type: :component do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider, recruitment_cycle: recruitment_cycle) }
  let(:level) { "secondary" }
  let(:degree_grade) { "not_required" }
  let(:course) do
    build(
      :course,
      provider: provider,
      degree_grade: degree_grade,
      degree_subject_requirements: "Maths A level.",
      level: level,
    )
  end

  before do
    render_inline(described_class.new(course: course))
  end

  context "when the degree section is incomplete" do
    let(:degree_grade) { nil }

    it "renders a link to the degree section" do
      expect(rendered_component).to have_link(
        "about degree requirements",
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
      let(:degree_grade) { "two_one" }

      it "renders 'An undergraduate degree at class 2:1 or above, or equivalent.'" do
        expect(rendered_component).to have_content("An undergraduate degree at class 2:1 or above, or equivalent.")
      end
    end

    context "when degree type is 'two_two'" do
      let(:degree_grade) { "two_two" }

      it "renders 'An undergraduate degree at class 2:2 or above, or equivalent.'" do
        expect(rendered_component).to have_content("An undergraduate degree at class 2:2 or above, or equivalent.")
      end
    end

    context "when degree type is 'third_class'" do
      let(:degree_grade) { "third_class" }

      it "renders 'An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent.'" do
        expect(rendered_component).to have_content("An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent.")
      end
    end

    context "when degree type is 'not_required'" do
      let(:degree_grade) { "not_required" }

      it "An undergraduate degree, or equivalent.'" do
        expect(rendered_component).to have_content("An undergraduate degree, or equivalent")
      end
    end

    context "when the course is for a Secondary subject" do
      let(:level) { "secondary" }

      it "renders standard text about degree subject requirement'" do
        expect(rendered_component).to have_content("Your degree subject should be in English or a similar subject. Otherwise you’ll need to prove your subject knowledge in some other way.")
      end
    end

    context "when the course is for a Primary subject" do
      let(:level) { "primary" }

      it "should not render text about degree subject requirement'" do
        expect(rendered_component).not_to have_content("Your degree subject should be in")
      end
    end

    context "when degree_subject_requirements and a degree grade are present" do
      let(:degree_grade) { "two_one" }

      it "renders the correct content for both attributes" do
        expect(rendered_component).to have_content("An undergraduate degree at class 2:1 or above, or equivalent.")
        expect(rendered_component).to have_content("Maths A level.")
      end
    end
  end
end
