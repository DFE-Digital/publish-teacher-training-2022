require "rails_helper"

feature "Edit course age range in years", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:age_range_in_years_page) { PageObjects::Page::Organisations::CourseAgeRange.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "subjects,courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course)
    age_range_in_years_page.load_with_course(course)
  end

  context "a course with no age range" do
    let(:course) do
      build(
        :course,
        age_range_in_years: nil,
        edit_options: {
          age_range_in_years: %w[11_to_16 11_to_18 14_to_19],
        },
        provider: provider,
      )
    end

    it "is not valid and returns error message" do
      age_range_in_years_page.save_button.click

      expect(age_range_in_years_page).to have_content("You need to pick an age range")
    end
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
      expect(age_range_in_years_page)
        .to have_selector('[for="course-age-range-in-years-11-to-16-field"]', text: "11 to 16")
      expect(age_range_in_years_page)
        .to have_selector('[for="course-age-range-in-years-11-to-18-field"]', text: "11 to 18")
      expect(age_range_in_years_page)
        .to have_selector('[for="course-age-range-in-years-14-to-19-field"]', text: "14 to 19")
      expect(age_range_in_years_page)
        .to have_selector('[for="course-age-range-in-years-other-field"]', text: "Another age range")
    end

    scenario "has the correct value selected" do
      expect(age_range_in_years_page)
        .to have_field("course-age-range-in-years-11-to-16-field", checked: true)
    end

    scenario "can be updated with a pre-determined age range" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch,
        200,
      )

      age_range_in_years_page.age_range_14_to_19.click
      age_range_in_years_page.save_button.click

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end

    scenario "can be updated with a custom age range" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch,
        200,
      )

      age_range_in_years_page.age_range_other.click
      age_range_in_years_page.age_range_from_field.set("14")
      age_range_in_years_page.age_range_to_field.set("19")
      age_range_in_years_page.save_button.click

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end

    context "displaying errors for custom age range selection" do
      scenario "From and To ages is missing" do
        age_range_in_years_page.age_range_other.click
        age_range_in_years_page.save_button.click

        expect(age_range_in_years_page).to be_displayed
        expect(age_range_in_years_page).to have_content(
          "You’ll need to correct some information.",
        )
        expect(age_range_in_years_page).to have_content(
          "Enter an age in From",
        )
        expect(age_range_in_years_page).to have_content(
          "Enter an age in To",
        )
      end

      scenario "From age is missing" do
        age_range_in_years_page.age_range_other.click
        age_range_in_years_page.age_range_from_field.set("16")
        age_range_in_years_page.save_button.click

        expect(age_range_in_years_page).to be_displayed
        expect(age_range_in_years_page).to have_content(
          "You’ll need to correct some information.",
        )
        expect(age_range_in_years_page).to have_content(
          "Enter an age in To",
        )
      end

      scenario "To age is missing" do
        age_range_in_years_page.age_range_other.click
        age_range_in_years_page.age_range_to_field.set("19")
        age_range_in_years_page.save_button.click

        expect(age_range_in_years_page).to be_displayed
        expect(age_range_in_years_page).to have_content(
          "You’ll need to correct some information.",
        )
        expect(age_range_in_years_page).to have_content(
          "Enter an age in From",
        )
      end

      scenario "From age is greater then To age" do
        age_range_in_years_page.age_range_other.click
        age_range_in_years_page.age_range_from_field.set("19")
        age_range_in_years_page.age_range_to_field.set("17")
        age_range_in_years_page.save_button.click

        expect(age_range_in_years_page).to be_displayed
        expect(age_range_in_years_page).to have_content(
          "You’ll need to correct some information.",
        )
        expect(age_range_in_years_page).to have_content(
          "Enter a valid age in From",
        )
      end

      scenario "To age is 4 years less than From age" do
        age_range_in_years_page.age_range_other.click
        age_range_in_years_page.age_range_from_field.set("17")
        age_range_in_years_page.age_range_to_field.set("17")
        age_range_in_years_page.save_button.click

        expect(age_range_in_years_page).to be_displayed
        expect(age_range_in_years_page).to have_content(
          "You’ll need to correct some information.",
        )
        expect(age_range_in_years_page).to have_content(
          "Enter a valid age in To",
        )
      end
    end
  end
end
