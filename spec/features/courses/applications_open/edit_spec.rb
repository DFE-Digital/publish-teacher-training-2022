require 'rails_helper'

feature 'Edit course applications open', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:applications_open_page) { PageObjects::Page::Organisations::CourseApplicationsOpen.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
      build(:provider).to_jsonapi(include: %i[courses accrediting_provider])
    )

    stub_course_request
    stub_course_details_tab
    applications_open_page.load_with_course(course)
  end

  context 'a course with an applications open from value of 2018-10-09' do
    let(:course) do
      build(
        :course,
        applications_open_from: '2018-10-09',
        provider: provider
      )
    end

    scenario 'can cancel changes' do
      click_on 'Cancel changes'
      expect(course_details_page).to be_displayed
    end

    scenario 'can navigate to the edit screen and back again' do
      course_details_page.load_with_course(course)
      click_on 'Change applications open date'
      expect(applications_open_page).to be_displayed
      click_on 'Back'
      expect(course_details_page).to be_displayed
    end

    scenario 'has the correct value selected' do
      expect(applications_open_page.applications_open_field.value).to eq('2018-10-09')
    end

    scenario 'selected radio to be checked' do
      expect(applications_open_page.applications_open_field).to be_checked
    end

    scenario 'selecting other updates radio checked value' do
      choose('course_applications_open_from_other')
      expect(applications_open_page.applications_open_field_other).to be_checked
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
            applications_open_from: "2018-11-11"
          }
        }
      }.to_json)

      choose('course_applications_open_from_other')
      fill_in 'course_day', with: '11'
      fill_in 'course_month', with: '11'
      fill_in 'course_year', with: '2018'


      click_on 'Save'
      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content('Your changes have been saved')
      expect(update_course_stub).to have_been_requested
    end
  end

  context 'a course with an applications open from value of 2018-12-12' do
    let(:course) do
      build(
        :course,
        applications_open_from: '2018-12-12',
        edit_options: {
          applications_open_from: %w[2018-10-09 other]
        },
        provider: provider
      )
    end

    scenario 'has the correct value selected' do
      expect(applications_open_page.applications_open_field_other).to be_checked
      expect(applications_open_page.applications_open_field_day.value).to eq('12')
      expect(applications_open_page.applications_open_field_month.value).to eq('12')
      expect(applications_open_page.applications_open_field_year.value).to eq('2018')
    end
  end

  def stub_course_request
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}/courses" \
      "/#{course.course_code}",
      course.to_jsonapi
    )
  end

  def stub_course_details_tab
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}" \
      "?include=sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: [:sites, :accrediting_provider, :recruitment_cycle, provider: :sites])
    )
  end
end
