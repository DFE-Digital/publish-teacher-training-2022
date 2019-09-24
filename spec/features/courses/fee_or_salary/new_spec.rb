require "rails_helper"

feature "new course fee or salary", type: :feature do
  let(:new_fee_or_salary_page) do
    PageObjects::Page::Organisations::Courses::NewFeeOrSalaryPage.new
  end

  let(:course) { build(:course, :new, provider: provider) }
  let(:provider) { build(:provider) }
  let(:course) { build(:course, :new, provider: provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_build_course
    stub_api_v2_build_course(funding_type: "fee")
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course

    visit new_provider_recruitment_cycle_courses_fee_or_salary_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  scenario "presents the correct choices" do
    expect(new_fee_or_salary_page).to have_funding_type_fields
    expect(new_fee_or_salary_page.funding_type_fields).to have_apprenticeship
    expect(new_fee_or_salary_page.funding_type_fields).to have_fee
    expect(new_fee_or_salary_page.funding_type_fields).to have_salaried
  end

  scenario "sends user to confirmation page" do
    new_fee_or_salary_page.funding_type_fields.fee.click
    new_fee_or_salary_page.save.click
    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
