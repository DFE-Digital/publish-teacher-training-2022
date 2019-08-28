require "rails_helper"

feature 'new course study mode', type: :feature do
  let(:new_study_mode_page) do
    PageObjects::Page::Organisations::CourseStudyMode.new
  end
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_new_resource(new_course)
  end

  scenario "user on new study mode page" do
    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/study_mode/new"

    expect(new_study_mode_page).to have_study_mode_fields
    expect(new_study_mode_page.study_mode_fields)
      .to have_selector('[for="course_study_mode_full_time"]', text: 'Full time')
    expect(new_study_mode_page.study_mode_fields)
      .to have_selector('[for="course_study_mode_part_time"]', text: 'Part time')
    expect(new_study_mode_page.study_mode_fields)
        .to have_selector('[for="course_study_mode_full_time_or_part_time"]', text: 'Full time or part time')
  end
end
