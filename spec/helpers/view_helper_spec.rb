require 'rails_helper'

RSpec.feature 'View helpers', type: :helper do
  describe "#govuk_link_to" do
    it "returns an anchor tag with the govuk-link class" do
      expect(helper.govuk_link_to('ACME SCITT', 'https://localhost:44364/organisations/A0')).to eq("<a class=\"govuk-link\" href=\"https://localhost:44364/organisations/A0\">ACME SCITT</a>")
    end
  end

  describe "#govuk_back_link_to" do
    it "returns an anchor tag with the govuk-back-link class" do
      expect(helper.govuk_back_link_to('https://localhost:44364/organisations/A0')).to eq("<a class=\"govuk-back-link\" href=\"https://localhost:44364/organisations/A0\">Back</a>")
    end
  end

  describe "#manage_ui_url" do
    it "returns full Manage Courses UI URL to the passed path" do
      expect(helper.manage_ui_url('/organisations/A0')).to eq("https://localhost:44364/organisations/A0")
    end
  end

  describe "#enrichment_error_url" do
    it "returns enrichment error URL" do
      course = Course.new(build(:course).attributes)
      expect(helper.enrichment_error_url(provider_code: 'A1', course: course, field: 'about_course')).to eq("/organisations/A1/#{course.recruitment_cycle_year}/courses/#{course.course_code}/about?display_errors=true#about_course_wrapper")
    end
  end

  describe "#provider_enrichment_error_url" do
    it "returns provider enrichment error URL" do
      provider = build(:provider)
      expect(helper.provider_enrichment_error_url(provider: provider, field: 'email')).to eq("/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/contact?display_errors=true#provider_email")
    end
  end

  describe "#classnames #cns" do
    it "returns joined classname strings" do
      expect(helper.cns('foo', 'bar')).to eq 'foo bar'
      expect(helper.cns('foo', bar: true)).to eq 'foo bar'
      expect(helper.cns('foo-bar': true)).to eq 'foo-bar'
      expect(helper.cns('foo-bar': false)).to eq ''
      expect(helper.cns({ foo: true }, bar: true)).to eq 'foo bar'
      expect(helper.cns(foo: true, bar: true)).to eq 'foo bar'
      expect(helper.cns('foo', { bar: true, duck: false }, 'baz', quux: true)).to eq 'foo bar baz quux'
      # Warning: different to reference implementation. Ignores integers.
      expect(helper.cns(nil, false, 'bar', Object, 0, 1, { baz: nil }, '')).to eq 'bar'
    end
  end
end
