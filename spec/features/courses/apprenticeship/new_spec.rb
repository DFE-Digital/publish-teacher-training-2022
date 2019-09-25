require "rails_helper"

feature "new course apprenticeship", type: :feature do
  let(:new_apprenticeship_page) do
    PageObjects::Page::Organisations::Courses::NewApprenticeshipPage.new
  end
  let(:course) { build(:course, :new, provider: provider) }
  let(:provider) { build(:provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
    stub_api_v2_build_course(funding_type: "apprenticeship")

    visit new_provider_recruitment_cycle_courses_apprenticeship_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  scenario "presents the correct choices" do
    expect(new_apprenticeship_page).to have_funding_type_fields
    expect(new_apprenticeship_page.funding_type_fields).to have_apprenticeship
    expect(new_apprenticeship_page.funding_type_fields).to have_fee
  end

  scenario "sends user to entry requirements" do
    new_apprenticeship_page.funding_type_fields.apprenticeship.click
    new_apprenticeship_page.save.click

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
