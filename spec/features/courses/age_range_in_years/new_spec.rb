require "rails_helper"

feature "new course age range", type: :feature do
  let(:new_age_range_page) do
    PageObjects::Page::Organisations::Courses::NewAgeRangePage.new
  end
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:course) do
    build(:course,
          :new,
          provider: provider,
          level: :primary)
  end

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course,
                       :new,
                       provider: provider,
                       level: :primary)
    stub_api_v2_new_resource(new_course)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([new_course], include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
  end

  scenario "sends user to entry requirements" do
    visit new_provider_recruitment_cycle_courses_age_range_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
    )

    stub_api_v2_build_course(age_range_in_years: "3_to_7")
    choose("course_age_range_in_years_3_to_7")
    click_on "Continue"


    expect(new_outcome_page).to be_displayed
  end
end
