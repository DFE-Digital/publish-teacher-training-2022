require "rails_helper"

feature 'new course', type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }
  let(:course) do
    build :course,
          :new,
          provider: provider,
          recruitment_cycle: recruitment_cycle
  end

  before do
    stub_omniauth
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource_collection([course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_new_resource(course)
  end

  scenario 'redirects and renders new course outcome page' do
    visit new_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year)

    expect(current_path).to eq new_provider_recruitment_cycle_courses_outcome_path(provider.provider_code, provider.recruitment_cycle_year)

    expect(new_outcome_page).to(
      be_displayed(
        recruitment_cycle_year: recruitment_cycle.year,
        provider_code: provider.provider_code
      )
    )

    # The qualifications for a new course that hasn't had it's level set just
    # happens to result in these qualifications. This will change when the new
    # course flow properly sets the level of the course.
    expect(new_outcome_page).to have_qualification_fields
    expect(new_outcome_page.qualification_fields).to have_qts
    expect(new_outcome_page.qualification_fields).to have_pgce_with_qts
    expect(new_outcome_page.qualification_fields).to have_pgde_with_qts
    new_outcome_page.qualification_fields.qts.click
  end
end
