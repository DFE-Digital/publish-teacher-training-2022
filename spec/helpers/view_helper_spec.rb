require 'rails_helper'

RSpec.feature 'View helpers', type: :helper do
  describe "#manage_ui_link_to" do
    it "returns a valid URL" do
      expect(helper.manage_ui_link_to('ACME SCITT', '/organisations/A0')).to eq("<a class=\"govuk-link\" href=\"https://localhost:44364/organisations/A0\">ACME SCITT</a>")
    end
  end

  describe "#manage_ui_link_to_back" do
    it "returns a valid URL" do
      expect(helper.manage_ui_link_to_back('/organisations')).to eq("<a class=\"govuk-back-link\" href=\"https://localhost:44364/organisations\">Back</a>")
    end
  end
end
