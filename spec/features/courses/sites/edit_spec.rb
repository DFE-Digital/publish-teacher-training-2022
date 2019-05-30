require 'rails_helper'

feature 'Edit course sites', type: :feature do
  let(:course) do
    jsonapi(
      :course,
      site_statuses: [jsonapi(:site_status, site: site1)],
      provider: provider
      )
  end
  let(:site1) { jsonapi(:site) }
  let(:site2) { jsonapi(:site) }
  let(:provider) do
    jsonapi(
      :provider,
      sites: [site1, site2]
    )
  end
  let(:edit_locations_path) do
    "/organisations/#{provider.provider_code}/courses/#{course.course_code}/locations"
  end

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=site_statuses.site,provider.sites",
      course.render
    )

    visit edit_locations_path
  end

  scenario 'viewing the edit locations page' do
    expect(page).to have_link('Back', href: provider_course_path(provider.provider_code, course.course_code))
    expect(page).to have_link('Cancel changes', href: provider_course_path(provider.provider_code, course.course_code))
    expect(find('h1')).to have_content('Locations')
    expect(find('.govuk-caption-xl')).to have_content(
      "#{course.name} (#{course.course_code})"
    )

    expect(page).to have_checked_field("course[site_statuses_attributes][0][#{site1.id}]")
    expect(page).to_not have_checked_field("course[site_statuses_attributes][0][#{site2.id}]")
  end
end
