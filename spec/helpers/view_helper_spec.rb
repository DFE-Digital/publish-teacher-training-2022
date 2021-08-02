require "rails_helper"

feature "View helpers", type: :helper do
  describe "#govuk_back_link_to" do
    it "returns an anchor tag with the govuk-back-link class" do
      expect(helper.govuk_back_link_to("https://localhost:44364/organisations/A0")).to eq("<a class=\"govuk-back-link govuk-!-display-none-print\" data-qa=\"page-back\" href=\"https://localhost:44364/organisations/A0\">Back</a>")
    end
  end

  describe "#bat_contact_mail_to" do
    context "with no link name" do
      it "returns BAT contact email address with a word break in the link name" do
        expect(helper.bat_contact_mail_to).to eq("<a class=\"govuk-link\" href=\"mailto:becomingateacher@digital.education.gov.uk\">becomingateacher<wbr>@digital.education.gov.uk</a>")
      end
    end

    context "with a link name" do
      it "returns BAT contact email address with the link name" do
        expect(helper.bat_contact_mail_to("Contact us")).to eq("<a class=\"govuk-link\" href=\"mailto:becomingateacher@digital.education.gov.uk\">Contact us</a>")
      end
    end

    context "with a subject" do
      it "returns BAT contact email address with a mailto: subject query" do
        expect(helper.bat_contact_mail_to(subject: "Feedback")).to eq("<a class=\"govuk-link\" href=\"mailto:becomingateacher@digital.education.gov.uk?subject=Feedback\">becomingateacher<wbr>@digital.education.gov.uk</a>")
      end
    end
  end

  describe "#enrichment_error_url" do
    it "returns enrichment error URL" do
      course = Course.new(build(:course).attributes)
      expect(helper.enrichment_error_url(provider_code: "A1", course: course, field: "about_course")).to eq("/organisations/A1/#{course.recruitment_cycle_year}/courses/#{course.course_code}/about?display_errors=true#about_course_wrapper")
    end

    it "returns enrichment error URL for base error" do
      course = Course.new(build(:course).attributes.merge(recruitment_cycle_year: "2022"))
      expect(helper.enrichment_error_url(provider_code: "A1", course: course, field: "base", message: "You must say whether you can sponsor visas")).to eq("/organisations/A1/2022/visas")
    end
  end

  describe "#provider_enrichment_error_url" do
    it "returns provider enrichment error URL" do
      provider = build(:provider)
      expect(helper.provider_enrichment_error_url(provider: provider, field: "email")).to eq("/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/contact?display_errors=true#provider_email")
    end
  end

  describe "#classnames #cns" do
    it "returns joined classname strings" do
      expect(helper.cns("foo", "bar")).to eq "foo bar"
      expect(helper.cns("foo", bar: true)).to eq "foo bar"
      expect(helper.cns('foo-bar': true)).to eq "foo-bar"
      expect(helper.cns('foo-bar': false)).to eq ""
      expect(helper.cns({ foo: true }, bar: true)).to eq "foo bar"
      expect(helper.cns(foo: true, bar: true)).to eq "foo bar"
      expect(helper.cns("foo", { bar: true, duck: false }, "baz", quux: true)).to eq "foo bar baz quux"
      # Warning: different to reference implementation. Ignores integers.
      expect(helper.cns(nil, false, "bar", Object, 0, 1, { baz: nil }, "")).to eq "bar"
    end
  end
end
