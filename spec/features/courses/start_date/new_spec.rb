require "rails_helper"

feature 'New course start date', type: :feature do
  let(:recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider)
    stub_api_v2_new_resource(new_course)
    stub_api_v2_resource(recruitment_cycle)
    stub_api_v2_resource_collection([new_course], include: "sites,provider.sites,accrediting_provider")
  end

  scenario "choose coure start date" do
    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/start-date/new"

    select 'September 2019'
    click_on 'Continue'

    expect(current_path).to eq confirmation_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
