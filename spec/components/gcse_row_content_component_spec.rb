require "rails_helper"

RSpec.describe GcseRowContentComponent, type: :component do
  let(:provider) { build(:provider) }

  context "when the gcse section is incomplete" do
    it "renders a link to the gcse section" do
      course = build(
        :course,
        provider: provider,
        accept_pending_gcse: nil,
        accept_gcse_equivalency: nil,
        accept_english_gcse_equivalency: nil,
        accept_maths_gcse_equivalency: nil,
        accept_science_gcse_equivalency: nil,
        additional_gcse_equivalencies: nil,
      )

      render_inline(described_class.new(course: course))

      expect(page).to have_link(
        "Enter GCSEs and equivalency test requirements",
        href: Rails.application.routes.url_helpers.gcses_pending_or_equivalency_tests_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          course.course_code,
        ),
      )
    end
  end

  context "when the gcse section is complete" do
    context "when pending gcse's are allowed" do
      it "renders 'Candidates with pending GCSEs will be considered'" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: true,
          accept_gcse_equivalency: true,
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Candidates with pending GCSEs will be considered")
      end
    end

    context "when pending gcse's are allowed" do
      it "renders 'Candidates with pending GCSEs will not be considered'" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: false,
          accept_gcse_equivalency: true,
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Candidates with pending GCSEs will not be considered")
      end
    end

    context "when course is primary" do
      it "renders 'Grade 4 (C) or above in English, maths and science'" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: true,
          accept_gcse_equivalency: true,
          level: "primary",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Grade 4 (C) or above in English, maths and science")
      end
    end

    context "when course is secondary" do
      it "renders 'Grade 4 (C) or above in English and maths'" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: true,
          accept_gcse_equivalency: true,
          level: "secondary",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Grade 4 (C) or above in English and maths")
      end
    end

    context "when course is not primary or secondary" do
      it "does not render conditional content" do
        course = build(
          :course,
          provider: provider,
          level: "Further education",
        )

        render_inline(described_class.new(course: course))

        expect(page).not_to have_content("Grade 4 (C) or above in English and maths")
        expect(page).not_to have_content("Grade 4 (C) or above in English, maths and science")
      end
    end

    context "when one equivalency is selected" do
      it "renders the correct content" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: true,
          accept_gcse_equivalency: true,
          accept_english_gcse_equivalency: true,
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Equivalency tests will be accepted in English")
      end
    end

    context "when two equivalencies are selected" do
      it "renders the correct content" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: true,
          accept_gcse_equivalency: true,
          accept_english_gcse_equivalency: true,
          accept_science_gcse_equivalency: true,
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Equivalency tests will be accepted in English and science")
      end
    end

    context "when all equivalencies are selected" do
      it "renders the correct content" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: true,
          accept_gcse_equivalency: true,
          accept_english_gcse_equivalency: true,
          accept_maths_gcse_equivalency: true,
          accept_science_gcse_equivalency: true,
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Equivalency tests will be accepted in English, maths and science")
      end
    end

    context "when additional_gcse_requirements are given" do
      it "renders the correct content" do
        course = build(
          :course,
          provider: provider,
          accept_pending_gcse: true,
          accept_gcse_equivalency: true,
          additional_gcse_equivalencies: "Geography",
        )

        render_inline(described_class.new(course: course))

        expect(page).to have_content("Geography")
      end
    end
  end
end
