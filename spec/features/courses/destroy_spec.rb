require "rails_helper"

feature "Delete course", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider, provider_code: "A0") }
  let(:course) do
    build :course,
          ucas_status: "new",
          provider: provider,
          recruitment_cycle: current_recruitment_cycle
  end

  let(:course_page) { PageObjects::Page::Organisations::Course.new }

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{course.recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}/" \
      "providers/#{provider.provider_code}" \
      "?include=courses.accrediting_provider",
      provider.to_jsonapi(include: %i[courses accrediting_provider]),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}/" \
      "providers/#{provider.provider_code}/" \
      "courses/#{course.course_code}" \
      "?include=subjects,sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: %i[provider sites]),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}/" \
      "providers/#{provider.provider_code}/" \
      "courses/#{course.course_code}",
      {},
      :delete, 200
    )

    course_page.load(provider_code: provider.provider_code, recruitment_cycle_year: course.recruitment_cycle.year, course_code: course.course_code)
  end

  scenario "confirming course code" do
    course_page.delete_link.click

    expect(find(".govuk-caption-xl")).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(find(".govuk-heading-xl")).to have_content(
      "Are you sure you want to delete this course?",
    )

    fill_in "Type in the course code to confirm", with: course.course_code
    click_on "Yes I’m sure – delete this course"

    expect(course_page.flash).to have_content(
      "#{course.name} (#{course.course_code}) has been deleted",
    )
    expect(current_path).to eq provider_recruitment_cycle_courses_path(provider.provider_code, course.recruitment_cycle_year)
  end

  context "incorrect course_code" do
    scenario "display validation errors" do
      course_page.delete_link.click

      expect(find(".govuk-caption-xl")).to have_content(
        "#{course.name} (#{course.course_code})",
      )
      expect(find(".govuk-heading-xl")).to have_content(
        "Are you sure you want to delete this course?",
      )

      fill_in "Type in the course code to confirm", with: "Z"
      click_on "Yes I’m sure – delete this course"

      expect(find(".govuk-error-summary")).to have_content(
        "Enter the course code (#{course.course_code}) to delete this course",
      )
    end
  end
end
