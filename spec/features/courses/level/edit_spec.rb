require 'rails_helper'

feature 'Edit course level', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:level_page) { PageObjects::Page::Organisations::CourseLevel.new }
  let(:details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider, level: :primary) }

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course)
    stub_api_v2_resource(
      course,
      include: 'sites,provider.sites,accrediting_provider'
    )

    level_page.load_with_course(course)
  end

  scenario 'can cancel changes' do
    click_on 'Cancel changes'
    expect(details_page).to be_displayed
  end

  # TODO: Enable me when we allow users to access this page.
  xscenario 'can navigate to the edit screen and back again' do
    details_page.load_with_course(course)
    click_on 'Change level'
    expect(level_page).to be_displayed
    click_on 'Back'
    expect(details_page).to be_displayed
  end

  scenario 'presents a choice for each level' do
    expect(level_page).to have_primary
    expect(level_page).to have_secondary
    expect(level_page).to have_further_education
  end

  scenario 'has the correct value selected' do
    expect(level_page.primary).to be_checked
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
          level: "secondary"
        }
      }
    }.to_json)

    choose 'Secondary'
    click_on 'Save'

    expect(details_page).to be_displayed
    expect(details_page.flash).to have_content('Your changes have been saved')
    expect(update_course_stub).to have_been_requested
  end
end
