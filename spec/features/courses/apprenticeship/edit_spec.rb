require "rails_helper"

feature "Edit course apprenticeship status", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:apprenticeship_page) { PageObjects::Page::Organisations::CourseApprenticeship.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider, accredited_body?: true) }

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course)
    apprenticeship_page.load_with_course(course)
  end

  context "A course that can be an apprenticeship" do
    let(:funding_type) { "apprenticeship" }
    let(:course) do
      build(
        :course,
        funding_type: funding_type,
        provider: provider,
        content_status: "draft",
      )
    end

    scenario "can navigate to the edit screen and back again" do
      course_details_page.load_with_course(course)
      click_on "Change if apprenticeship"
      expect(apprenticeship_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "presents the correct choices" do
      expect(apprenticeship_page).to have_funding_type_fields
      expect(apprenticeship_page.funding_type_fields)
        .to have_selector('[for="course_funding_type_apprenticeship"]', text: "Yes")
      expect(apprenticeship_page.funding_type_fields)
        .to have_selector('[for="course_funding_type_fee"]', text: "No")
    end

    scenario "clicking no sets funding type to fee" do
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
              funding_type: "fee",
            },
          },
        }.to_json,
      )

      apprenticeship_page.funding_type_fee.click
      apprenticeship_page.save_button.click

      expect(patch_stub).to have_been_requested
    end
  end
end
