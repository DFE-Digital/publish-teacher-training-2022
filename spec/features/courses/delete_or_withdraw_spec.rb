require 'rails_helper'

feature 'Getting rid of a course', type: :feature do
  let(:provider) { jsonapi(:provider) }
  let(:provider_attributes) { provider.attributes }
  let(:course) do
    jsonapi(
      :course,
      ucas_status: ucas_status,
      provider: provider
    ).render
  end
  let(:course_attributes) { course[:data][:attributes] }
  let(:course_page) { PageObjects::Page::Organisations::Course.new }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/#{provider_attributes[:provider_code]}/courses/#{course_attributes[:course_code]}?include=sites,provider.sites,accrediting_provider",
      course
    )

    course_page.load(provider_code: provider_attributes[:provider_code], course_code: course_attributes[:course_code])
  end

  context "for a running course" do
    let(:ucas_status) { 'running' }

    scenario 'withdrawing can be requested via support' do
      course_page.withdraw_link.click

      expect(find('.govuk-caption-xl')).to have_content(
        "#{course_attributes[:name]} (#{course_attributes[:course_code]})"
      )
      expect(find('.govuk-heading-xl')).to have_content(
        "Are you sure you want to withdraw this course?"
      )
    end

    scenario "deletion isn't possible" do
      expect(course_page).to_not have_delete_link
    end
  end

  context "for a new course" do
    let(:ucas_status) { 'new' }

    scenario 'deletion can be requested via support' do
      course_page.delete_link.click

      expect(find('.govuk-caption-xl')).to have_content(
        "#{course_attributes[:name]} (#{course_attributes[:course_code]})"
      )
      expect(find('.govuk-heading-xl')).to have_content(
        "Are you sure you want to delete this course?"
      )
    end

    scenario "withdrawing isn't possible" do
      expect(course_page).to_not have_withdraw_link
    end
  end

  context "for a non-running course" do
    let(:ucas_status) { 'not_running' }

    scenario "deletion isn't possible" do
      expect(course_page).to_not have_delete_link
    end

    scenario "withdrawing isn't possible" do
      expect(course_page).to_not have_withdraw_link
    end
  end
end
