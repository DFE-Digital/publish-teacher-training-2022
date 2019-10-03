require "rails_helper"

feature "Edit course age range in years", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:age_range_in_years_page) { PageObjects::Page::Organisations::CourseAgeRange.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}?include=subjects,courses.accrediting_provider",
      build(:provider).to_jsonapi(include: %i[subjects courses accrediting_provider]),
    )

    stub_course_request
    stub_course_details_tab
    age_range_in_years_page.load_with_course(course)
  end

  context "a course with an age range of 11 to 16" do
    let(:course) do
      build(
        :course,
        age_range_in_years: "11_to_16",
        edit_options: {
          age_range_in_years: %w[11_to_16 11_to_18 14_to_19],
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
      click_on "Change age range"
      expect(age_range_in_years_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "presents a choice for each age range" do
      expect(age_range_in_years_page).to have_age_range_fields
      expect(age_range_in_years_page.age_range_fields)
        .to have_selector('[for="course_age_range_in_years_11_to_16"]', text: "11 to 16")
      expect(age_range_in_years_page.age_range_fields)
        .to have_selector('[for="course_age_range_in_years_11_to_18"]', text: "11 to 18")
      expect(age_range_in_years_page.age_range_fields)
          .to have_selector('[for="course_age_range_in_years_14_to_19"]', text: "14 to 19")
    end

    scenario "has the correct value selected" do
      expect(age_range_in_years_page.age_range_fields)
        .to have_field("course_age_range_in_years_11_to_16", checked: true)
    end

    scenario "can be updated" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      )

      choose("course_age_range_in_years_14_to_19")
      click_on "Save"

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end
  end

  def stub_course_request
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}/courses" \
      "/#{course.course_code}",
      course.to_jsonapi,
    )
  end

  def stub_course_details_tab
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}" \
      "?include=subjects,sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: [:subjects, :sites, :accrediting_provider, :recruitment_cycle, provider: :sites]),
    )
  end
end
