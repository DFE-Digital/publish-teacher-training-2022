require 'rails_helper'

feature 'Handling Forbidden responses from the backend', type: :feature do
  let(:unauthorized_page) { PageObjects::Page::Unauthorized.new }

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/2019", {}, :get, 403)
  end

  it 'Does not redirect the page' do
    visit "/organisations/A0/"
    expect(page.current_path).to eq("/organisations/A0")
  end

  it 'Renders the unauthorized page' do
    visit "/organisations/A0/"
    expect(unauthorized_page.unauthorized_text).to be_visible
  end
end
