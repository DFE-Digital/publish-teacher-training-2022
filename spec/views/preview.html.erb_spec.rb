require "rails_helper"

describe "Rendering financial support information" do
  let(:preview_course_page) { PageObjects::Page::Organisations::CoursePreview.new }

  context "course has no financial incentives" do
    it "renders the 'loan' partial" do
      course = build(:course)

      render "courses/preview/financial_support", course: course.decorate

      preview_course_page.load(rendered)

      expect(preview_course_page).to have_selector("[data-qa=course__loan_details]")
    end
  end

  context "course is excluded from offering bursaries" do
    it "renders the 'loan' partial" do
      english = build(:subject, subject_name: "English", busary_amount: "3000")
      pe = build(:subject, subject_name: "PE")
      course = build(:course, name: "PE with English", subjects: [english, pe])

      render "courses/preview/financial_support", course: course.decorate

      preview_course_page.load(rendered)

      expect(preview_course_page).to have_selector("[data-qa=course__loan_details]")
    end
  end

  context "course has a bursary" do
    it "renders the 'bursary' partial" do
      mathematics = build(:subject, :mathematics, bursary_amount: "3000")
      course = build(:course, subjects: [mathematics]).decorate

      render "courses/preview/financial_support", course: course, locals: { course: course }

      preview_course_page.load(rendered)

      expect(preview_course_page).to have_selector("[data-qa=course__bursary_details]")
    end
  end

  context "course has bursary and scholarship" do
    it "renders the 'scholarship_and_bursary' partial" do
      mathematics = build(:subject, :mathematics, bursary_amount: "3000", scholarship: "6000")
      course = build(:course, subjects: [mathematics]).decorate

      render "courses/preview/financial_support", course: course, locals: { course: course }

      preview_course_page.load(rendered)

      expect(preview_course_page).to have_selector("[data-qa=course__scholarship_and_bursary_details]")
    end
  end

  context "course has salary" do
    it "renders the 'salaried' partial" do
      course = build(:course, funding_type: "salary")

      render "courses/preview/financial_support", course: course.decorate

      preview_course_page.load(rendered)

      expect(preview_course_page).to have_selector("[data-qa=course__salary_details]")
    end
  end
end
