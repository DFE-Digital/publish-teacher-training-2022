require "rails_helper"

describe "sessions" do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build :provider }
  let(:providers) do
    [
      build(:provider, courses: [build(:course)]),
      build(:provider, courses: [build(:course)]),
      build(:provider, courses: [build(:course)]),
    ]
  end

  let(:providers_response) do
    resource_list_to_jsonapi(providers, meta: { count: 3 })
  end

  let(:provider_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:root_page) { PageObjects::Page::RootPage.new }

  it "redirects users back to where they were going on sign-in" do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers", providers_response)
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}", provider.to_jsonapi)

    visit_dfe_sign_in("/signin")
    visit "/organisations/#{provider.provider_code}"

    expect(provider_page).to be_displayed(provider_code: provider.provider_code)
  end

  it "redirects users to root when they go straight to the signin page" do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.to_jsonapi)
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers?page[page]=1", providers_response)

    visit_dfe_sign_in "/signin"

    expect(root_page).to be_displayed
  end
end

def visit_dfe_sign_in(url)
  visit url
  click_button("Sign in using DfE Sign-in")
end
