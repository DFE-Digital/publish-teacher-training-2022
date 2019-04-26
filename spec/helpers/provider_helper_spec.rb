require 'rails_helper'

feature 'View helpers', type: :helper do
  let(:email) { 'ab+test@c.com' }
  let(:html_escaped_version_of_email) { 'ab%2Btest%40c.com' }
  let(:provider) { jsonapi(:provider).to_resource }

  describe "#add_course_link" do
    it "builds a link" do
      expect(helper.add_course_link(email, provider)).to eq("<a class=\"govuk-button govuk-!-margin-bottom-2\" rel=\"noopener noreferrer\" target=\"_blank\" href=\"#{CGI::escapeHTML(helper.add_course_url(email, provider))}\">Add a new course</a>")
    end
  end

  describe "#add_location_link" do
    it "builds a link" do
      expect(helper.add_location_link(email, provider)).to eq("<a class=\"govuk-button govuk-!-margin-bottom-2\" rel=\"noopener noreferrer\" target=\"_blank\" href=\"#{CGI::escapeHTML(helper.add_location_url(email, provider))}\">Add a location</a>")
    end
  end

  describe "#add_course_url" do
    describe "for accredited bodies" do
      let(:provider) { jsonapi(:provider, accredited_body?: true).to_resource }

      it "returns correct google form" do
        expect(helper.add_course_url(email, provider)).to start_with(Settings.google_forms.new_course_for_accredited_bodies.url)
        expect(helper.add_course_url(email, provider)).to include(html_escaped_version_of_email)
        expect(helper.add_course_url(email, provider)).to include(provider.attributes[:provider_code])
      end
    end

    describe "for non-accredited bodies" do
      let(:provider) { jsonapi(:provider, accredited_body?: false).to_resource }

      it "returns correct google form" do
        expect(helper.add_course_url(email, provider)).to start_with(Settings.google_forms.new_course_for_unaccredited_bodies.url)
        expect(helper.add_course_url(email, provider)).to include(html_escaped_version_of_email)
        expect(helper.add_course_url(email, provider)).to include(provider.attributes[:provider_code])
      end
    end
  end

  describe "#add_location_url" do
    it "returns a pre-populated google form URL" do
      expect(helper.add_location_url(email, provider)).to start_with(Settings.google_forms.add_location.url)
      expect(helper.add_location_url(email, provider)).to include(html_escaped_version_of_email)
      expect(helper.add_location_url(email, provider)).to include(provider.attributes[:provider_code])
    end
  end
end
