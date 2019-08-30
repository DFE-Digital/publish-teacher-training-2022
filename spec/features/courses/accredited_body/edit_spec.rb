require 'rails_helper'

id_selector = ->(code) { "course_accrediting_provider_code_#{code.downcase}" }
for_selector = ->(code) { "[for=\"#{id_selector.(code)}\"]" }

feature 'Edit accredited body', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:accredited_body_page) { PageObjects::Page::Organisations::CourseAccreditedBody.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:accrediting_provider_1) { build(:provider) }
  let(:accrediting_provider_2) { build(:provider) }
  let(:accredited_bodies) {
    [
      { "provider_name": accrediting_provider_1.provider_name, "provider_code" => accrediting_provider_1.provider_code },
      { "provider_name": accrediting_provider_2.provider_name, "provider_code" => accrediting_provider_2.provider_code },
    ]
  }

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course, include: "accrediting_provider")
    stub_api_v2_resource(course, include: "sites,provider.sites,accrediting_provider")

    accredited_body_page.load_with_course(course)
  end

  context 'a course with no accredited body' do
    let(:provider) { build(:provider) }
    let(:course) { build(:course, provider: provider) }

    scenario 'can cancel changes' do
      click_on 'Cancel changes'
      expect(course_details_page).to be_displayed
    end

    xscenario 'can navigate to the edit screen and back again' do
      course_details_page.load_with_course(course)
      click_on 'Change outcome'
      expect(accredited_body_page).to be_displayed
      click_on 'Back'
      expect(course_details_page).to be_displayed
    end
  end

  context 'a course with accredited bodies' do
    let(:provider) { build(:provider, accredited_bodies: accredited_bodies) }
    let(:course) do
      build(
        :course,
        provider: provider,
        accrediting_provider: accrediting_provider_2,
      )
    end

    scenario 'presents a choice for each accrediting body' do
      expect(accredited_body_page).to have_accredited_body_fields
      expect(accredited_body_page.accredited_body_fields)
        .to have_selector(
          for_selector.(accrediting_provider_1.provider_code),
          text: accrediting_provider_1.provider_name
        )
      expect(accredited_body_page.accredited_body_fields)
        .to have_selector(
          for_selector.(accrediting_provider_2.provider_code),
          text: accrediting_provider_2.provider_name
        )
    end

    scenario 'has the correct value selected' do
      expect(accredited_body_page.accredited_body_fields)
        .to have_field(
          id_selector.(accrediting_provider_2.provider_code),
          checked: true
        )
    end

    scenario 'can be updated' do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      ).with(body: {
        data: {
          course_code: course.course_code,
          type: "courses",
          attributes: {
            accrediting_provider_code: accrediting_provider_1.provider_code,
          }
        }
      }.to_json)

      choose(accrediting_provider_1.provider_name)
      click_on 'Save'

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content('Your changes have been saved')
      expect(update_course_stub).to have_been_requested
    end
  end
end
