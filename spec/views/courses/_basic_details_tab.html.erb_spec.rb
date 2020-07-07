require "rails_helper"

RSpec.describe "courses/_basic_details_tab.html.erb" do
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider).decorate }
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
        expect(page.title_detail.actions).to_not have_content("Change course title")
      end

      it "admin only help panel is not displayed" do
        expect(page.title_detail.value).to_not have_content("Only admins can make changes")
      end
    end

    context "when an admin" do
      let(:current_user) do
        { "admin" => true }
      end

      it "is displayed" do
        expect(page.title_detail.actions).to have_content("Change course title")
      end

      it "admin only help panel is displayed" do
        expect(page.title_detail.value).to have_content("Only admins can make changes")
      end
    end
  end
end
