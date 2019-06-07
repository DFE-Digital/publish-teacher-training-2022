require 'rails_helper'

feature 'Edit course sites', type: :feature do
  let(:course) do
    jsonapi(
      :course,
      sites: [site1],
      provider: provider,
      accrediting_provider: provider
    )
  end
  let(:site1) { jsonapi(:site, location_name: 'Site one') }
  let(:site2) { jsonapi(:site, location_name: 'Site two') }
  let(:provider) do
    jsonapi(
      :provider,
      sites: [site1, site2]
    )
  end
  let(:course_page) { PageObjects::Page::Organisations::Course.new }
  let(:locations_page) { PageObjects::Page::Organisations::CourseLocations.new }

  let!(:sync_courses_request_stub) do
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}/sync_with_search_and_compare",
      {}, :post, 201
    )
  end

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course.render
    )
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites",
      course.render
    )

    course_page.load(provider_code: provider.provider_code, course_code: course.course_code)
    course_page.edit_locations_link.click
    expect(locations_page)
      .to be_displayed(provider_code: provider.provider_code, course_code: course.course_code)
  end

  scenario 'viewing the edit locations page' do
    expect(page).to have_link('Back', href: provider_course_path(provider.provider_code, course.course_code))
    expect(page).to have_link('Cancel changes', href: provider_course_path(provider.provider_code, course.course_code))
    expect(locations_page.title).to have_content('Locations')
    expect(locations_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )

    expect(page).to have_checked_field("course[site_statuses_attributes][0][selected]")
    expect(page).to_not have_checked_field("course[site_statuses_attributes][1][selected]")
  end

  context 'adding locations' do
    before do
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}",
        {}, :patch, 200
      ).with(body: {
        data: {
          course_code: course.course_code,
          type: "courses",
          relationships: {
            sites: {
              data: [
                { type: "sites", id: site1.id.to_s },
                { type: "sites", id: site2.id.to_s }
              ]
            },
          },
          attributes: {}
        }
      }.to_json)
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course.render
      )
    end

    scenario 'adding a location' do
      check(site2.location_name, allow_label_click: true)

      locations_page.save.click

      expect(locations_page.success_summary).to have_content(
        'Course locations saved'
      )
      expect(locations_page.title).to have_content(course.course_code)
      expect(sync_courses_request_stub).to have_been_requested
    end
  end

  describe "with validations errors" do
    before do
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}",
        build(:error), :patch, 422
      ).with(body: {
        data: {
          course_code: course.course_code,
          type: "courses",
          relationships: {
            sites: {
              data: []
            },
          },
          attributes: {}
        }
      }.to_json)
    end

    scenario 'displays validation errors' do
      uncheck(site1.location_name, allow_label_click: true)

      locations_page.save.click

      expect(page.title).to have_content('Error:')
      expect(locations_page).to be_displayed(provider_code: provider.provider_code, course_code: course.course_code)
      expect(locations_page.error_summary).to have_content('Removing all locations would prevent people from applying to this course')
    end
  end
end
