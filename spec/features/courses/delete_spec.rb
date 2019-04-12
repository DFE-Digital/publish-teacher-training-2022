require 'rails_helper'

feature 'Delete course', type: :feature do
  let(:course) do
    jsonapi(
      :course,
      provider: jsonapi(:provider)
    ).render
  end
  let(:course_attributes) { course[:data][:attributes] }

  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request(
      "/providers/AO/courses/#{course_attributes[:course_code]}?include=site_statuses.site,provider.sites",
      course
    )
  end

  scenario 'viewing the show courses page' do
    visit "/organisations/AO/courses/#{course_attributes[:course_code]}/delete"

    expect(find('.govuk-caption-xl')).to have_content(
      "#{course_attributes[:name]} (#{course_attributes[:course_code]})"
    )
    expect(find('.govuk-heading-xl')).to have_content(
      "Are you sure you want to delete this course?"
    )
  end
end
