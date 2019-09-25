RSpec.feature "View helpers", type: :helper do
  describe "#enrichment_error_link" do
    context "with a course" do
      before do
        @provider = Provider.new(build(:provider).attributes)
        @course = Course.new(build(:course).attributes)
      end

      it "returns correct content" do
        expect(helper.enrichment_error_link(:course, "about_course", "Something about the course"))
          .to eq("<a class=\"govuk-link govuk-!-display-block\" href=\"/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about?display_errors=true#about_course_wrapper\">Something about the course</a>")
      end
    end
  end

  describe "#enrichment_summary_label" do
    it "returns correct content" do
      expect(helper.enrichment_summary_label(:course, "About course", %w[about_course])).to eq('<dt class="govuk-summary-list__key">About course</dt>')
    end

    context "with errors" do
      before do
        @provider = Provider.new(build(:provider).attributes)
        @course = Course.new(build(:course).attributes)
        @errors = { about_course: ["Something about the course"] }
      end

      it "returns correct content" do
        expect(helper.enrichment_summary_label(:course, "About course", [:about_course])).to eq("<dt class=\"govuk-summary-list__key app-course-parts__fields__label--error\"><span>About course</span><a class=\"govuk-link govuk-!-display-block\" href=\"/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about?display_errors=true#about_course_wrapper\">Something about the course</a></dt>")
      end
    end
  end

  describe "#enrichment_summary_value" do
    it "returns the value" do
      expect(helper.enrichment_summary_value("Something about the course", %w[about]))
        .to eq('<dd class="govuk-summary-list__value govuk-summary-list__value--truncate" data-qa="enrichment__about">Something about the course</dd>')
    end

    it "returns 'empty' when value is empty" do
      expect(helper.enrichment_summary_value("", %w[about]))
        .to eq('<dd class="govuk-summary-list__value govuk-summary-list__value--truncate app-course-parts__fields__value--empty" data-qa="enrichment__about">Empty</dd>')
    end
  end

  describe "#enrichment_summary_item" do
    it "returns correct content" do
      expect(helper.enrichment_summary_item(:course, "About course", "Something about the course", %w[about]))
        .to eq('<div class="govuk-summary-list__row"><dt class="govuk-summary-list__key">About course</dt><dd class="govuk-summary-list__value govuk-summary-list__value--truncate" data-qa="enrichment__about">Something about the course</dd></div>')
    end
  end
end
