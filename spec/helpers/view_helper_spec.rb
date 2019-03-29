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

  describe "#manage_ui_url" do
    it "returns full Manage Courses UI URL to the passed path" do
      expect(helper.manage_ui_course_page_url(provider_code: 'A1', course_code: 'X130')).to eq("https://localhost:44364/organisation/A1/course/self/X130")
    end
  end
end
