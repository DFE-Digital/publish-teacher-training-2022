require "rails_helper"

describe "Rendering financial support information" do
  placeholder_partial_path = "courses/preview/financial_support/_placeholder"

  before do
    allow(Settings).to receive(:financial_support_placeholder_cycle)
      .and_return(financial_support_placeholder_cycle)
  end

  subject do
    render "courses/preview/financial_support", course: course.decorate

    preview_course_page = PageObjects::Page::Organisations::CoursePreview.new
    preview_course_page.load(rendered)

    preview_course_page
  end

  context "course has no financial incentives" do
    let(:course) { build(:course) }

    context "financial_support_placeholder_cycle is nil" do
      let(:financial_support_placeholder_cycle) { nil }

      it "renders the 'loan' partial" do
        expect(subject).to have_loan_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle not the same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i + 1
      end

      it "renders the 'loan' partial" do
        expect(subject).to have_loan_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i
      end

      it "does not renders the 'loan' partial" do
        expect(subject).to_not have_loan_details
      end

      it "renders the 'placeholder' partial" do
        expect(subject).to render_template(partial: placeholder_partial_path)
      end
    end
  end

  context "course is excluded from offering bursaries" do
    let(:english) do
      build(:subject, subject_name: "English", busary_amount: "3000")
    end

    let(:pe) do
      build(:subject, subject_name: "PE")
    end

    let(:course) do
      build(:course, name: "PE with English", subjects: [english, pe])
    end

    context "financial_support_placeholder_cycle is nil" do
      let(:financial_support_placeholder_cycle) { nil }

      it "renders the 'loan' partial" do
        expect(subject).to have_loan_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle not the same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i + 1
      end

      it "renders the 'loan' partial" do
        expect(subject).to have_loan_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i
      end

      it "does not renders the 'loan' partial" do
        expect(subject).to_not have_loan_details
      end

      it "renders the 'placeholder' partial" do
        expect(subject).to render_template(partial: placeholder_partial_path)
      end
    end
  end

  context "course has a bursary" do
    let(:mathematics) do
      build(:subject, :mathematics, bursary_amount: "3000")
    end
    let(:course) do
      build(:course, subjects: [mathematics])
    end

    context "financial_support_placeholder_cycle is nil" do
      let(:financial_support_placeholder_cycle) { nil }

      it "renders the 'bursary' partial" do
        expect(subject).to have_bursary_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle not the same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i + 1
      end

      it "renders the 'bursary' partial" do
        expect(subject).to have_bursary_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i
      end

      it "does not renders the 'bursary' partial" do
        expect(subject).to_not have_bursary_details
      end

      it "renders the 'placeholder' partial" do
        expect(subject).to render_template(partial: placeholder_partial_path)
      end
    end
  end

  context "course has bursary and scholarship" do
    let(:mathematics) do
      build(:subject, :mathematics, bursary_amount: "3000", scholarship: "6000")
    end
    let(:course) do
      build(:course, subjects: [mathematics])
    end

    context "financial_support_placeholder_cycle is nil" do
      let(:financial_support_placeholder_cycle) { nil }

      it "renders the 'scholarship_and_bursary' partial" do
        expect(subject).to have_scholarship_and_bursary_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle not the same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i + 1
      end

      it "renders the 'scholarship_and_bursary' partial" do
        expect(subject).to have_scholarship_and_bursary_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i
      end

      it "does not renders the 'scholarship_and_bursary' partial" do
        expect(subject).to_not have_scholarship_and_bursary_details
      end

      it "renders the 'placeholder' partial" do
        expect(subject).to render_template(partial: placeholder_partial_path)
      end
    end
  end

  context "course has salary" do
    let(:course) do
      build(:course, funding_type: "salary")
    end

    context "financial_support_placeholder_cycle is nil" do
      let(:financial_support_placeholder_cycle) { nil }

      it "renders the 'salary' partial" do
        expect(subject).to have_salary_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle not the same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i + 1
      end

      it "renders the 'salary' partial" do
        expect(subject).to have_salary_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end

    context "financial_support_placeholder_cycle same as course recruitment_cycle_year" do
      let(:financial_support_placeholder_cycle) do
        course.recruitment_cycle_year.to_i
      end

      it "renders the 'salary' partial" do
        expect(subject).to have_salary_details
      end

      it "does not renders the 'placeholder' partial" do
        expect(subject).to_not render_template(partial: placeholder_partial_path)
      end
    end
  end
end
