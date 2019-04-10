require 'rails_helper'

feature 'View helpers', type: :helper do
  describe "#add_course_link" do
    it "returns correct google form for accrediting providers" do
      provider = jsonapi(:provider, accredited_body?: true).to_resource
      expect(helper.add_course_link(provider)).to eq("<a class=\"govuk-button govuk-!-margin-bottom-2\" rel=\"noopener noreferrer\" target=\"_blank\" href=\"https://forms.gle/ktbyArGW5EyiMppf9\">Add a new course</a>")
    end

    it "returns correct google form for non-accrediting providers" do
      provider = jsonapi(:provider, accredited_body?: false).to_resource
      expect(helper.add_course_link(provider)).to eq("<a class=\"govuk-button govuk-!-margin-bottom-2\" rel=\"noopener noreferrer\" target=\"_blank\" href=\"https://forms.gle/WEokN2S4qPcPAZcr5\">Add a new course</a>")
    end
  end
end
