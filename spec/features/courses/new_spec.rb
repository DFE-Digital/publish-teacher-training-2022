require "rails_helper"

feature 'new course outcome', type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_new_resource(new_course)
  end

  scenario 'creating a new course' do
    # Until we have a .../courses/new endpoint go straight to the outcome
    visit "/organisations/#{provider.provider_code}/#{recruitment_cycle.year}" \
          "/courses/outcome/new"

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
