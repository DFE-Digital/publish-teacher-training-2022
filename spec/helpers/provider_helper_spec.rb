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

  describe "#visa_sponsorship_status" do
    it "returns correct value when one or more values is nil" do
      provider = build(
        :provider,
        can_sponsor_student_visa: nil,
        can_sponsor_skilled_worker_visa: true,
      )
      expect(helper.visa_sponsorship_status(provider)).to match(
        "Can you sponsor visas?"
      )
      expect(helper.visa_sponsorship_status(provider)).to match(
        "Select if you can sponsor visas"
      )
    end

    it "returns correct value when only student visas are sponsored" do
      provider = build(
        :provider,
        can_sponsor_student_visa: true,
        can_sponsor_skilled_worker_visa: false,
      )
      expect(helper.visa_sponsorship_status(provider)).to eq(
        "You can sponsor Student visas",
      )
    end

    it "returns correct value when only skilled worker visas are sponsored" do
      provider = build(
        :provider,
        can_sponsor_student_visa: false,
        can_sponsor_skilled_worker_visa: true,
      )
      expect(helper.visa_sponsorship_status(provider)).to eq(
        "You can sponsor Skilled Worker visas",
      )
    end

    it "returns correct value when both kinds of visa are sponsored" do
      provider = build(
        :provider,
        can_sponsor_student_visa: true,
        can_sponsor_skilled_worker_visa: true,
      )
      expect(helper.visa_sponsorship_status(provider)).to eq(
        "You can sponsor Student and Skilled Worker visas",
      )
    end

    it "returns correct value when neither kind of visa is sponsored" do
      provider = build(
        :provider,
        can_sponsor_student_visa: false,
        can_sponsor_skilled_worker_visa: false,
      )
      expect(helper.visa_sponsorship_status(provider)).to eq(
        "You cannot sponsor visas",
      )
    end
  end
end
