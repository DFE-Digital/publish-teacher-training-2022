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
          level: :primary,
          study_mode: "full_time_or_part_time",
          gcse_subjects_required_using_level: true,
          applications_open_from: "2019-10-09",
          start_date: "2019-10-09")
  end

  before do
    stub_omniauth(provider: provider)
    resource_list_to_jsonapi([provider])
    stub_api_v2_resource(provider)
    stub_api_v2_resource(build(:provider, provider_code: "A2"))
    stub_api_v2_resource(build(:provider, provider_code: "A4"))
    new_course = build(:course,
                       :new,
                       provider: provider,
                       level: :primary)
    stub_api_v2_new_resource(new_course)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([new_course], include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_build_course
    stub_api_v2_build_course(age_range_in_years: "3_to_7")
  end

  scenario "sends user to entry requirements" do
    visit_new_age_range_page

    choose("course_age_range_in_years_3_to_7")
    new_age_range_page.continue.click

    expect(new_outcome_page).to be_displayed
  end

  scenario "sends user back to course confirmation" do
    visit_new_age_range_page(goto_confirmation: true)

    choose("course_age_range_in_years_3_to_7")
    new_age_range_page.continue.click

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  def visit_new_age_range_page(**query_params)
    visit signin_path
    visit new_provider_recruitment_cycle_courses_age_range_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      query_params,
    )
  end
end
