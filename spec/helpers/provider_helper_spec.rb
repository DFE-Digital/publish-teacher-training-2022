require 'rails_helper'

feature 'View helpers', type: :helper do
  let(:email) { 'ab+test@c.com' }
  let(:html_escaped_version_of_email) { 'ab%2Btest%40c.com' }
  let(:provider) { build(:provider) }

  describe "#add_course_link" do
    it "builds a link" do
      expect(helper.add_course_link(email, provider, is_current_cycle: true)).to eq("<a class=\"govuk-button govuk-!-margin-bottom-2\" rel=\"noopener noreferrer\" target=\"_blank\" href=\"#{CGI::escapeHTML(helper.add_course_url(email, provider, is_current_cycle: true))}\">Add a new course</a>")
    end
  end

  describe "#add_course_url" do
    describe "for accredited bodies" do
      let(:provider) { build(:provider, accredited_body?: true) }

      it "returns correct google form for the current cycle" do
        expect(helper.add_course_url(email, provider, is_current_cycle: true)).to start_with(Settings.google_forms.current_cycle.new_course_for_accredited_bodies.url)
        expect(helper.add_course_url(email, provider, is_current_cycle: true)).to include(html_escaped_version_of_email)
        expect(helper.add_course_url(email, provider, is_current_cycle: true)).to include(provider.attributes[:provider_code])
      end

      it "returns correct google form for the next cycle" do
        expect(helper.add_course_url(email, provider, is_current_cycle: false)).to start_with(Settings.google_forms.next_cycle.new_course_for_accredited_bodies.url)
        expect(helper.add_course_url(email, provider, is_current_cycle: false)).to include(html_escaped_version_of_email)
        expect(helper.add_course_url(email, provider, is_current_cycle: false)).to include(provider.attributes[:provider_code])
      end
    end

    describe "for non-accredited bodies" do
      let(:provider) { build(:provider, accredited_body?: false) }

      it "returns correct google form for the current cycle" do
        expect(helper.add_course_url(email, provider, is_current_cycle: true)).to start_with(Settings.google_forms.current_cycle.new_course_for_unaccredited_bodies.url)
        expect(helper.add_course_url(email, provider, is_current_cycle: true)).to include(html_escaped_version_of_email)
        expect(helper.add_course_url(email, provider, is_current_cycle: true)).to include(provider.attributes[:provider_code])
      end

      it "returns correct google form for the next cycle" do
        expect(helper.add_course_url(email, provider, is_current_cycle: false)).to start_with(Settings.google_forms.next_cycle.new_course_for_unaccredited_bodies.url)
        expect(helper.add_course_url(email, provider, is_current_cycle: false)).to include(html_escaped_version_of_email)
        expect(helper.add_course_url(email, provider, is_current_cycle: false)).to include(provider.attributes[:provider_code])
      end
    end
  end
end
