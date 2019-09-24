require "rails_helper"

feature "Getting rid of a course", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider, provider_code: "A0") }
  let(:course) do
    build :course,
          ucas_status: ucas_status,
          provider: provider,
          recruitment_cycle: current_recruitment_cycle
  end

  let(:course_page) { PageObjects::Page::Organisations::Course.new }

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{course.recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}/" \
      "providers/#{provider.provider_code}/" \
      "courses/#{course.course_code}" \
      "?include=sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: %i[provider sites]),
    )

    course_page.load(provider_code: provider.provider_code, recruitment_cycle_year: course.recruitment_cycle.year, course_code: course.course_code)
  end

  context "for a running course" do
    let(:ucas_status) { "running" }

    scenario "withdrawing can be requested via support" do
      course_page.withdraw_link.click

      expect(find(".govuk-caption-xl")).to have_content(
        "#{course.name} (#{course.course_code})",
      )
      expect(find(".govuk-heading-xl")).to have_content(
        "Are you sure you want to withdraw this course?",
      )
    end

    scenario "deletion isn't possible" do
      expect(course_page).to_not have_delete_link
    end
  end

  context "for a new course" do
    let(:ucas_status) { "new" }

    scenario "deletion can be requested via support" do
      course_page.delete_link.click

      expect(find(".govuk-caption-xl")).to have_content(
        "#{course.name} (#{course.course_code})",
      )
      expect(find(".govuk-heading-xl")).to have_content(
        "Are you sure you want to delete this course?",
      )
    end

    scenario "withdrawing isn't possible" do
      expect(course_page).to_not have_withdraw_link
    end
  end

  context "for a non-running course" do
    let(:ucas_status) { "not_running" }

    scenario "deletion isn't possible" do
      expect(course_page).to_not have_delete_link
    end

    scenario "withdrawing isn't possible" do
      expect(course_page).to_not have_withdraw_link
    end
  end
end
