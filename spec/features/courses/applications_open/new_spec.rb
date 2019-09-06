require "rails_helper"

feature 'new course applications open', type: :feature do
  let(:new_applications_open_page) do
    PageObjects::Page::Organisations::Courses::NewApplicationsOpenPage.new
  end

  let(:provider) { build(:provider) }
  let(:course) { build(:course, :new, provider: provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
    stub_api_v2_build_course(applications_open_from: '2018-10-09')
  end

  scenario "sends user to confirmation page" do
    visit new_provider_recruitment_cycle_courses_applications_open_path(provider.provider_code, provider.recruitment_cycle_year)

    expect(new_applications_open_page.applications_open_field).to_not be_checked
    expect(new_applications_open_page.applications_open_field_other).to_not be_checked

    expect(new_applications_open_page.applications_open_field_day.value).to be_nil
    expect(new_applications_open_page.applications_open_field_month.value).to be_nil
    expect(new_applications_open_page.applications_open_field_year.value).to be_nil

    expect(new_applications_open_page).to have_applications_open_field
    expect(new_applications_open_page).to have_applications_open_field_other

    new_applications_open_page.applications_open_field.click

    click_on 'Continue'

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
