require "rails_helper"

feature "new course fee or salary", type: :feature do
  let(:new_fee_or_salary_page) do
    PageObjects::Page::Organisations::Courses::NewFeeOrSalaryPage.new
  end
  let(:root_page) { PageObjects::Page::RootPage.new }

  let(:course) { build(:course, :new, provider: provider) }
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider, accrediting_provider: build(:provider)) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth(provider: provider)
    stub_api_v2_resource(provider)
    stub_api_v2_build_course
    stub_api_v2_build_course(funding_type: "fee")
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
    stub_api_v2_request(
      "/recruitment_cycles/2020/providers?page[page]=1",
      resource_list_to_jsonapi([provider], meta: { count: 1 }),
    )
  end

  scenario "presents the correct choices" do
    visit_fee_or_salary
    expect(new_fee_or_salary_page).to have_funding_type_fields
    expect(new_fee_or_salary_page.funding_type_fields).to have_apprenticeship
    expect(new_fee_or_salary_page.funding_type_fields).to have_fee
    expect(new_fee_or_salary_page.funding_type_fields).to have_salaried
  end

  context "Selecting values" do
    let(:next_step_page) do
      PageObjects::Page::Organisations::Courses::NewStudyModePage.new
    end
    let(:selected_fields) { { funding_type: "fee" } }
    let(:build_course_with_selected_value_request) { stub_api_v2_build_course(selected_fields) }

    before do
      visit_fee_or_salary
      new_fee_or_salary_page.funding_type_fields.fee.click
      new_fee_or_salary_page.continue.click
    end

    it_behaves_like "a course creation page"
  end

  scenario "sends user to confirmation page" do
    visit_fee_or_salary
    visit_fee_or_salary(goto_confirmation: true)
    new_fee_or_salary_page.funding_type_fields.fee.click
    new_fee_or_salary_page.continue.click
    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  context "Error handling" do
    let(:course) do
      c = build(:course, provider: provider)
      c.errors.add(:funding_type, "Invalid")
      c.errors.add(:program_type, "Invalid")
      c
    end

    scenario do
      visit_fee_or_salary
      new_fee_or_salary_page.funding_type_fields.fee.click
      new_fee_or_salary_page.continue.click
      expect(new_fee_or_salary_page.error_flash.text).to include("Funding type Invalid")
      expect(new_fee_or_salary_page.error_flash.text).to include("Program type Invalid")
    end
  end

  context "Page title" do
    before do
      visit_fee_or_salary
    end
    scenario "It displays the correct title" do
      expect(page.title).to start_with("Is it fee paying or salaried? ")
    end
  end

  def visit_fee_or_salary(**query_params)
    visit new_provider_recruitment_cycle_courses_fee_or_salary_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      query_params,
    )
  end
end
