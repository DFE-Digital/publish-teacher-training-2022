require "rails_helper"

feature "Edit course SEND", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:send_page) { PageObjects::Page::Organisations::Send.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course)

    send_page.load_with_course(course)
  end

  context "editing is send" do
    context "if the backend has indicated that is send can be edited" do
      let(:course) do
        build(
          :course,
          edit_options: {
            show_is_send: true,
          },
          provider: provider,
        )
      end

      scenario "should show the edit link" do
        course_details_page.load_with_course(course)
        expect(course_details_page.is_send).to have_change_link
      end
    end

    context "if the backend has indicated that is send cannot be edited" do
      let(:course) do
        build(
          :course,
          edit_options: {
            show_is_send: false,
          },
          provider: provider,
        )
      end

      scenario "should not show the edit link" do
        course_details_page.load_with_course(course)
        expect(course_details_page.is_send).to_not have_change_link
      end
    end
  end

  context "a course with a send value of true" do
    let(:course) do
      build(
        :course,
        is_send: "1",
        content_status: "draft",
        edit_options: {
          is_send_options: %w[0 1],
          show_is_send: true,
        },
        provider: provider,
      )
    end

    scenario "can navigate to the edit screen and back again" do
      course_details_page.load_with_course(course)
      click_on "Change SEND"
      expect(send_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "has the correct value selected" do
      expect(send_page.send_field.value).to eq("1")
    end
  end
end
