require "rails_helper"

describe "recruitment_cycles/show.html", type: :view do
  let(:recruitment_cycle_page) { PageObjects::Page::Organisations::RecruitmentCycle.new }
  let(:accredited_body) { build(:provider, :accredited_body) }
  let(:current_recruitment_cycle) { build :recruitment_cycle }
  let(:next_recruitment_cycle) { build :recruitment_cycle, :next_cycle }

  module CurrentUserMethod
    def current_user; end
  end

  describe "current cycle" do
    before do
      view.extend(CurrentUserMethod)
      allow(view).to receive(:params).and_return({ year: current_recruitment_cycle.year })
      assign(:recruitment_cycle, current_recruitment_cycle)
    end

    describe "when accredited body user is viewing the current cycle" do
      before do
        allow(Allocation).to receive(:journey_mode).and_return("open")
        assign(:provider, accredited_body)
        render template: "recruitment_cycles/show"
        recruitment_cycle_page.load(rendered)
      end

      it "shows the current cycle" do
        expect(recruitment_cycle_page.title).to have_content(current_recruitment_cycle.title)
        expect(recruitment_cycle_page).to have_about_organisation_link
        expect(recruitment_cycle_page).to have_courses_link
        expect(recruitment_cycle_page).to have_locations_link
        expect(recruitment_cycle_page).to have_courses_as_accredited_body_link
        expect(recruitment_cycle_page).to have_request_for_pe_link
      end
    end

    describe "when accredited body user is viewing the current cycle" do
      before do
        assign(:provider, build(:provider))
        render template: "recruitment_cycles/show"
        recruitment_cycle_page.load(rendered)
      end

      it "shows the current cycle" do
        expect(recruitment_cycle_page.title).to have_content(current_recruitment_cycle.title)
        expect(recruitment_cycle_page).to have_about_organisation_link
        expect(recruitment_cycle_page).to have_courses_link
        expect(recruitment_cycle_page).to have_locations_link
        expect(recruitment_cycle_page).to have_no_courses_as_accredited_body_link
        expect(recruitment_cycle_page).to have_no_request_for_pe_link
      end
    end
  end

  describe "next cycle" do
    before do
      view.extend(CurrentUserMethod)
      allow(view).to receive(:params).and_return({ year: next_recruitment_cycle.year })
      assign(:recruitment_cycle, next_recruitment_cycle)
    end

    describe "when accredited body user is viewing the next cycle" do
      before do
        assign(:provider, accredited_body)
        render template: "recruitment_cycles/show"
        recruitment_cycle_page.load(rendered)
      end

      it "shows the next cycle" do
        expect(recruitment_cycle_page.title).to have_content(next_recruitment_cycle.title)
        expect(recruitment_cycle_page).to have_about_organisation_link
        expect(recruitment_cycle_page).to have_courses_link
        expect(recruitment_cycle_page).to have_locations_link
        expect(recruitment_cycle_page).to have_courses_as_accredited_body_link
        expect(recruitment_cycle_page).to have_no_request_for_pe_link
      end
    end

    describe "when training provider user is viewing the next cycle" do
      before do
        assign(:provider, build(:provider))
        render template: "recruitment_cycles/show"
        recruitment_cycle_page.load(rendered)
      end

      it "shows the next cycle" do
        expect(recruitment_cycle_page.title).to have_content(next_recruitment_cycle.title)
        expect(recruitment_cycle_page).to have_about_organisation_link
        expect(recruitment_cycle_page).to have_courses_link
        expect(recruitment_cycle_page).to have_locations_link
        expect(recruitment_cycle_page).to have_no_courses_as_accredited_body_link
        expect(recruitment_cycle_page).to have_no_request_for_pe_link
      end
    end
  end
end
