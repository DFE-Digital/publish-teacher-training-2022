require 'rails_helper'

feature 'About course', type: :feature do
  let(:course) do
    jsonapi(
      :course,
      provider: jsonapi(:provider, provider_code: 'A0')
    ).render
  end
  let(:course_attributes) { course[:data][:attributes] }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/AO/courses/#{course_attributes[:course_code]}?include=site_statuses.site,provider.sites,accrediting_provider",
      course
    )
  end

  scenario 'viewing the about courses page' do
    visit about_provider_course_path('AO', course_attributes[:course_code])

    expect(find('.govuk-caption-xl')).to have_content(
      "#{course_attributes[:name]} (#{course_attributes[:course_code]})"
    )
    expect(find('.govuk-heading-xl')).to have_content(
      "About this course"
    )
    expect(page).to have_field("About this course")
    expect(page).to have_field("Interview process (optional)")
    expect(page).to have_field("How school placements work")
  end
end
