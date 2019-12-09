require "rails_helper"

feature "Edit course fee or salary status", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:fee_or_salary_page) { PageObjects::Page::Organisations::CourseFeeOrSalary.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider, accredited_body?: false) }

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider, include: "subjects,courses.accrediting_provider")

    stub_api_v2_resource(course)
    stub_course_details_tab
    fee_or_salary_page.load_with_course(course)
  end

  context "A course belonging to a non-accredited body" do
    let(:funding_type) { "fee" }

    let(:course) do
      build(
        :course,
        funding_type: funding_type,
        provider: provider,
        content_status: "draft",
      )
    end

    scenario "can cancel changes" do
      click_on "Cancel changes"
      expect(course_details_page).to be_displayed
    end

    scenario "can navigate to the edit screen and back again" do
      course_details_page.load_with_course(course)
      click_on "Change fee or salary"
      expect(fee_or_salary_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "presents the correct choices" do
      expect(fee_or_salary_page).to have_funding_type_fields
      expect(fee_or_salary_page.funding_type_fields)
        .to have_apprenticeship
      expect(fee_or_salary_page.funding_type_fields)
        .to have_fee
      expect(fee_or_salary_page.funding_type_fields)
        .to have_salary
    end

    scenario "clicking salaried sets funding type to salaried" do
      patch_stub = stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}/courses" \
        "/#{course.course_code}",
        {},
        :patch,
        body: {
          data: {
            course_code: course.course_code,
            type: "courses",
            attributes: {
              funding_type: "salary",
            },
          },
        }.to_json,
      )

      fee_or_salary_page.funding_type_fields.salary.click
      fee_or_salary_page.save.click

      expect(patch_stub).to have_been_requested
    end

    scenario "It displays the correct title" do
      expect(page.title).to start_with("Is it fee paying or salaried? ")
    end
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
