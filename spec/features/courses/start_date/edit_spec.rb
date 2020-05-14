require "rails_helper"

feature "Edit course start date", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:start_date_page) { PageObjects::Page::Organisations::CourseStartDate.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course)
    start_date_page.load_with_course(course)
  end

  context "editing start date" do
    context "if the backend has indicated that start date can be edited" do
      let(:course) do
        build(
          :course,
          edit_options: {
            show_start_date: true,
            start_dates: ["October 2019", "November 2019"],
          },
          provider: provider,
        )
      end

      scenario "should show the edit link" do
        course_details_page.load_with_course(course)
        expect(course_details_page).to have_edit_start_date_link
      end
    end

    context "if the backend has indicated that start date cannot be edited" do
      let(:course) do
        build(
          :course,
          edit_options: {
            show_start_date: false,
            start_dates: ["October 2019", "November 2019"],
          },
          provider: provider,
        )
      end

      scenario "should not show the edit link" do
        course_details_page.load_with_course(course)
        expect(course_details_page).to_not have_edit_start_date_link
      end
    end
  end

  context "a course with a start date of october 2019" do
    let(:course) do
      build(
        :course,
        start_date: "October 2019",
        content_status: "draft",
        edit_options: {
          start_dates: ["September 2019", "October 2019", "November 2019"],
          show_start_date: true,
        },
        provider: provider,
      )
    end

    scenario "can cancel changes" do
      click_on "Cancel changes"
      expect(course_details_page).to be_displayed
    end

    scenario "can navigate to the edit screen and back again" do
      course_details_page.load_with_course(course)
      click_on "Change start date"
      expect(start_date_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "defaults to the current value" do
      expect(start_date_page.start_date_field.value).to eq "October 2019"
    end

    scenario "presents a choice for each start date" do
      expect(start_date_page).to have_start_date_field
      expect(start_date_page.start_date_field)
        .to have_selector('[value="October 2019"]')
      expect(start_date_page.start_date_field)
        .to have_selector('[value="November 2019"]')
    end

    scenario "has the correct value selected" do
      expect(start_date_page.start_date_field.value).to eq("October 2019")
    end

    scenario "can be updated" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch,
        200,
      )

      select("November 2019")
      click_on "Save"

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end
  end
end
