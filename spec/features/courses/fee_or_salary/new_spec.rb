require "rails_helper"

feature 'new course fee or salary', type: :feature do
  let(:new_fee_or_salary_page) do
    PageObjects::Page::Organisations::Courses::NewFeeOrSalaryPage.new
  end

  let(:course) { build(:course, :new, provider: provider) }
  let(:provider) { build(:provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_build_course
    stub_api_v2_build_course(program_type: 'pg_teaching_apprenticeship')
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_new_resource(new_course)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([new_course], include: "sites,provider.sites,accrediting_provider")
  end

  scenario "sends user to confirmation page" do
    visit new_provider_recruitment_cycle_courses_fee_or_salary_path(provider.provider_code, provider.recruitment_cycle_year)

    expect(new_fee_or_salary_page).to have_program_type_fields


    expect(new_fee_or_salary_page.program_type_fields)
      .to have_selector('[for="course_program_type_pg_teaching_apprenticeship"]', text: 'Teaching apprenticeship (with salary)')
    expect(new_fee_or_salary_page.program_type_fields)
      .to have_selector('[for="course_program_type_school_direct_training_programme"]', text: 'Fee paying (no salary)')
    expect(new_fee_or_salary_page.program_type_fields)
      .to have_selector('[for="course_program_type_school_direct_salaried_training_programme"]', text: 'Salaried')

    new_fee_or_salary_page.program_type_fields.pg_teaching_apprenticeship.click

    click_on 'Continue'

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
