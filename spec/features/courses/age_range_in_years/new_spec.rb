require "rails_helper"

feature 'new course outcome', type: :feature do
  let(:new_age_range_page) do
    PageObjects::Page::Organisations::Courses::NewAgeRangePage.new
  end
  let(:provider) { build(:provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:course) do
    build(:course,
          :new,
          provider: provider,
          level: 'primary',
          edit_options: {
            age_range_in_years: %w[3_to_7 5_to_11 7_to_11 7_to_14]
          })
  end

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course,
                       :new,
                       provider: provider,
                       level: 'primary',
                       edit_options: {
                         age_range_in_years: %w[3_to_7 5_to_11 7_to_11 7_to_14]
                       })
    stub_api_v2_new_resource(new_course)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([new_course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
  end

  scenario "sends user to entry requirements" do
    visit new_provider_recruitment_cycle_courses_age_range_path(
      provider.provider_code,
      provider.recruitment_cycle_year
    )

    choose('course_age_range_in_years_3_to_7')
    click_on 'Continue'

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
