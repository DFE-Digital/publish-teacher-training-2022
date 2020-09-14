require "rails_helper"

feature "View helpers", type: :helper do
  let(:email) { "ab+test@c.com" }
  let(:html_escaped_version_of_email) { "ab%2Btest%40c.com" }
  let(:provider) { build(:provider, accredited_body?: accredited_body, recruitment_cycle: recruitment_cycle) }

  describe "#add_course_url" do
    describe "for accredited bodies" do
      let(:accredited_body) { true }

      context "with current cycle" do
        let(:recruitment_cycle) { build(:recruitment_cycle) }

        it "returns correct google form for the current cycle" do
          expect(helper.add_course_url(email, provider)).to start_with(Settings.google_forms.current_cycle.new_course_for_accredited_bodies.url)
          expect(helper.add_course_url(email, provider)).to include(html_escaped_version_of_email)
          expect(helper.add_course_url(email, provider)).to include(provider.attributes[:provider_code])
        end
      end

      context "with next cycle" do
        let(:recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }

        it "returns correct google form for the next cycle" do
          expect(helper.add_course_url(email, provider)).to start_with(Settings.google_forms.next_cycle.new_course_for_accredited_bodies.url)
          expect(helper.add_course_url(email, provider)).to include(html_escaped_version_of_email)
          expect(helper.add_course_url(email, provider)).to include(provider.attributes[:provider_code])
        end
      end
    end

    describe "for non-accredited bodies" do
      let(:accredited_body) { false }

      context "with current cycle" do
        let(:recruitment_cycle) { build(:recruitment_cycle) }

        it "returns correct google form for the current cycle" do
          expect(helper.add_course_url(email, provider)).to start_with(Settings.google_forms.current_cycle.new_course_for_unaccredited_bodies.url)
          expect(helper.add_course_url(email, provider)).to include(html_escaped_version_of_email)
          expect(helper.add_course_url(email, provider)).to include(provider.attributes[:provider_code])
        end
      end

      context "with next cycle" do
        let(:recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }

        it "returns correct google form for the next cycle" do
          expect(helper.add_course_url(email, provider)).to start_with(Settings.google_forms.next_cycle.new_course_for_unaccredited_bodies.url)
          expect(helper.add_course_url(email, provider)).to include(html_escaped_version_of_email)
          expect(helper.add_course_url(email, provider)).to include(provider.attributes[:provider_code])
        end
      end
    end
  end
end
