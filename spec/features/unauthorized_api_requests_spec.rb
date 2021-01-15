require "rails_helper"

feature "Handling Unauthorized responses from the backend", type: :feature do
  let(:no_providers_page) { PageObjects::Page::Organisations::NoProviders.new }

  before do
    signed_in_user
    stub_api_v2_request("/recruitment_cycles/#{Settings.current_cycle}", {}, :get, 401)
  end

  it "renders the no-providers page" do
    visit "/organisations/A0/"
    expect(no_providers_page.no_providers_text).to be_visible
  end
end
