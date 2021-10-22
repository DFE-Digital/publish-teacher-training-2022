require "rails_helper"

feature "Withdraw course", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider, provider_code: "A0") }
  let(:course) do
    build :course,
          ucas_status: "running",
          provider: provider,
          recruitment_cycle: current_recruitment_cycle
  end

  let(:course_page) { PageObjects::Page::Organisations::Course.new }
  let(:courses_page) { PageObjects::Page::Organisations::CoursesPage.new }

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}/" \
      "providers/#{provider.provider_code}/" \
      "courses/#{course.course_code}/withdraw",
      {},
      :post,
      200,
    )

    courses_page.load(provider_code: provider.provider_code, recruitment_cycle_year: course.recruitment_cycle.year)
    course_page.load(provider_code: provider.provider_code, recruitment_cycle_year: course.recruitment_cycle.year, course_code: course.course_code)
  end

  scenario "confirming course code" do
    course_page.withdraw_link.click

    expect(find(".govuk-caption-l")).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(find(".govuk-heading-l")).to have_content(
      "Are you sure you want to withdraw this course?",
    )

    fill_in "Type in the course code to confirm", with: course.course_code
    click_on "Yes I’m sure – withdraw this course"

    expect(course_page.flash).to have_content(
      "#{course.name} (#{course.course_code}) has been withdrawn",
    )
    expect(current_path).to eq provider_recruitment_cycle_courses_path(provider.provider_code, course.recruitment_cycle_year)
  end

  context "incorrect course_code" do
    scenario "display validation errors" do
      course_page.withdraw_link.click

      expect(find(".govuk-caption-l")).to have_content(
        "#{course.name} (#{course.course_code})",
      )
      expect(find(".govuk-heading-l")).to have_content(
        "Are you sure you want to withdraw this course?",
      )

      fill_in "Type in the course code to confirm", with: "Z"
      click_on "Yes I’m sure – withdraw this course"

      expect(course_page.error_summary).to have_content(
        "There is a problem",
      )

      expect(course_page.withdraw_error).to have_content(
        "Enter the course code (#{course.course_code}) to withdraw this course",
      )
    end
  end

  context "the course is already withdrawn" do
    let(:course) do
      build :course,
            ucas_status: "running",
            provider: provider,
            recruitment_cycle: current_recruitment_cycle,
            content_status: "withdrawn"
    end

    scenario "display validation errors" do
      course_page.withdraw_link.click

      fill_in "Type in the course code to confirm", with: "Z"
      click_on "Yes I’m sure – withdraw this course"

      expect(courses_page.error_summary).to have_content(
        "#{course.course_code} has already been withdrawn",
      )
    end
  end
end
