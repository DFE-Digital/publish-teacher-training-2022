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
    let(:summary_list) { GovukComponent::SummaryListComponent.new }
    subject { render(summary_list) }

    context "with a value" do
      before do
        helper.enrichment_summary(summary_list, :course, "About course", "Something about the course", %w[about])
      end

      it "injects the provided content into the provided summary list row" do
        expect(subject).to have_css(%(.govuk-summary-list__row[data-qa="enrichment__about"]))
        expect(subject).to have_css(".govuk-summary-list__key", text: "About course")
        expect(subject).to have_css(".govuk-summary-list__value.app-summary-list__value--truncate", text: "Something about the course")
      end
    end

    context "with no value" do
      before do
        helper.enrichment_summary(summary_list, :course, "About course", "", %w[about])
      end

      it "returns 'Empty' when value is empty" do
        expect(subject).to have_css(".govuk-summary-list__key", text: "About course")

        expect(subject).to have_css(".govuk-summary-list__value.app-summary-list__value--truncate") do |value_container|
          expect(value_container).to have_css("span.app-!-colour-muted", text: "Empty")
        end
      end
    end

    context "with errors" do
      let(:error_message) { "Enter something about the course" }
      before do
        @provider = Provider.new(build(:provider).attributes)
        @course = Course.new(build(:course).attributes)
        @errors = { about_course: [error_message] }
      end

      before do
        helper.enrichment_summary(summary_list, :course, "About course", "", [:about_course])
      end

      it "renders a value containing an error link within inset text" do
        expect(subject).to have_css(".govuk-summary-list__key", text: "About course")
        expect(subject).to have_css(".govuk-summary-list__value > .app-inset-text--error > a", text: error_message)

        expect(subject).to have_link(error_message, href: "/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about?display_errors=true#about_course_wrapper")
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
