require "rails_helper"

RSpec.feature "View helpers", type: :helper do
  describe "#enrichment_error_link" do
    context "with a course" do
      before do
        @provider = Provider.new(build(:provider).attributes)
        @course = Course.new(build(:course).attributes)
      end

      it "returns correct content" do
        expect(helper.enrichment_error_link(:course, "about_course", "Something about the course"))
          .to eq("<div class=\"govuk-inset-text app-inset-text--narrow-border app-inset-text--error\"><a class=\"govuk-link\" href=\"/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about?display_errors=true#about_course_wrapper\">Something about the course</a></div>")
      end
    end
  end

  describe "#enrichment_summary" do
    it "returns correct content" do
      output = helper.enrichment_summary(:course, "About course", "Something about the course", %w[about])
      expect(output[:key]).to eq("About course")
      expect(output[:value]).to eq("Something about the course")
      expect(output[:classes]).to eq("app-summary-list__row--truncate")
      expect(output[:html_attributes]).to eq({ data: { qa: "enrichment__about" } })
    end

    context "with no value" do
      it "returns 'Empty' when value is empty" do
        output = helper.enrichment_summary(:course, "About course", "", %w[about])
        expect(output[:value]).to eq("<span class=\"app-!-colour-muted\">Empty</span>")
      end
    end

    context "with errors" do
      before do
        @provider = Provider.new(build(:provider).attributes)
        @course = Course.new(build(:course).attributes)
        @errors = { about_course: ["Enter something about the course"] }
      end

      it "returns correct content" do
        output = helper.enrichment_summary(:course, "About course", "", [:about_course])
        expect(output[:key]).to eq("About course")
        expect(output[:value]).to eq("<div class=\"govuk-inset-text app-inset-text--narrow-border app-inset-text--error\"><a class=\"govuk-link\" href=\"/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about?display_errors=true#about_course_wrapper\">Enter something about the course</a></div>")
      end
    end
  end

  describe "#markdown" do
    it "converts markdown to HTML" do
      expect(helper.markdown("test")).to eq("<p class=\"govuk-body\">test</p>")
    end

    it "converts markdown lists to HTML lists" do
      expect(helper.markdown("* test\n* another test")).to include("<li>test</li>")
    end

    it "ignores emphasis markdown" do
      output = helper.markdown("This does not have *emphasis*\n**something important**\n***super***")
      expect(output).to include("This does not have *emphasis*")
      expect(output).to include("**something important**")
      expect(output).to include("***super***")
    end

    it "converts quotes to smart quotes" do
      output = helper.markdown("\"Wow – what's this...\", O'connor asked.")
      expect(output).to eq("<p class=\"govuk-body\">“Wow – what’s this…”, O’connor asked.</p>")
    end

    # Redcarpet fixes out of the box
    it "fixes incorrect markdown links" do
      output = helper.markdown("[Google] (https://www.google.com)")
      expect(output).to include("<a href=\"https://www.google.com\" class=\"govuk-link\">Google</a>")
    end
  end

  describe "#smart_quotes" do
    it "converts quotes to smart quotes" do
      output = helper.smart_quotes("\"Wow – what's this...\", O'connor asked.")
      expect(output).to include("“Wow – what’s this…”, O’connor asked.")
    end

    it "does not convert three consecutive dashes to an em dash" do
      output = helper.smart_quotes("https://www.londonmet.ac.uk/courses/postgraduate/pgce-secondary-science-with-biology---pgce")
      expect(output).to include("https://www.londonmet.ac.uk/courses/postgraduate/pgce-secondary-science-with-biology---pgce")
    end

    context "when nil" do
      it "returns empty string" do
        expect(helper.smart_quotes(nil)).to be_blank
      end
    end
  end
end
