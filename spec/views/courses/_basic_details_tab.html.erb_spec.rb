require "rails_helper"

RSpec.describe "courses/_basic_details_tab.html.erb" do
  let(:recruitment_cycle_year) { "2021" }
  let(:current_recruitment_cycle) { build :recruitment_cycle, year: recruitment_cycle_year }
  let(:provider) { build(:provider, recruitment_cycle: current_recruitment_cycle) }
  let(:course) { build(:course, provider: provider, recruitment_cycle: current_recruitment_cycle).decorate }
  let(:details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:page) do
    details_page.load(rendered)
    details_page
  end

  before do
    assign(:course, course)
    assign(:provider, course.provider)
    render partial: "courses/basic_details_tab", locals: { course: course, current_user: current_user }
  end

  describe "change link for course title" do
    context "when not an admin" do
      let(:current_user) do
        { "admin" => false }
      end

      it "is not displayed" do
        expect(page.name).to_not have_change_link
      end

      it "admin only help panel is not displayed" do
        expect(page.name.value).to_not have_content("Only admins can make changes")
      end
    end

    context "when an admin" do
      let(:current_user) do
        { "admin" => true }
      end

      it "is displayed" do
        expect(page.name).to have_change_link
      end

      it "admin only help panel is displayed" do
        expect(page.name.value).to have_content("Only admins can make changes")
      end
    end

    context "when course for 2022 cycle" do
      let(:recruitment_cycle_year) { "2022" }
      let(:current_user) do
        { "admin" => true }
      end

      it "does not render the UCAS Apply: GCSE requirements for applicants row" do
        expect(page).to_not have_content("UCAS Apply: GCSE requirements for applicants")
      end
    end

    context "when course for 2021 cycle" do
      let(:current_user) do
        { "admin" => true }
      end

      it "renders the UCAS Apply: GCSE requirements for applicants row" do
        expect(page).to have_content("UCAS Apply: GCSE requirements for applicants")
      end
    end
  end
end
