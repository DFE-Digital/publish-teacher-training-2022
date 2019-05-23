require 'rails_helper'

feature 'Preview course', type: :feature do
  let(:course_jsonapi) { jsonapi(:course, name: 'English', provider: provider) }
  let(:provider)       { jsonapi(:provider, provider_code: 'AO') }
  let(:course)          { course_jsonapi.to_resource }
  let(:course_response) { course_jsonapi.render }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}?include=site_statuses.site,provider.sites,accrediting_provider",
      course_response
    )
  end

  let(:preview_course_page) { PageObjects::Page::Organisations::CoursePreview.new }

  scenario 'viewing the show courses page' do
    visit preview_provider_course_path('AO', course.course_code)

    expect(preview_course_page.title).to have_content(
      "#{course.name} (#{course.course_code})"
    )

    expect(preview_course_page.sub_title).to have_content(
      provider.provider_name
    )

    expect(preview_course_page.description).to have_content(
      course.description
    )
  end
end
