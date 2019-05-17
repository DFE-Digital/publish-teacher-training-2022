require 'rails_helper'

feature 'Locations', type: :feature do
  let(:provider) { jsonapi(:provider) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/#{provider.provider_code}?include=sites",
      provider.render
    )
  end

  context 'without validation errors' do
    before do
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/sites",
        nil,
        :post
      )
    end

    scenario 'Adding a location' do
      visit provider_sites_path(provider.provider_code)

      click_on 'Add a location'

      fill_in 'Name', with: 'New site'
      fill_in 'Building and street', with: 'New building and street'
      fill_in 'Town or city', with: 'New town'
      fill_in 'County', with: 'New county'
      fill_in 'Postcode', with: 'SW1A 1AA'
      select 'London', from: 'Region of UK'

      click_on 'Save'

      expect(page).to have_content('Your location has been created')
    end
  end

  context "with validations errors" do
    before do
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/sites",
        build(:error),
        :post,
        422
      )
    end

    scenario 'Adding a location with validation errors' do
      visit new_provider_site_path(provider.provider_code)

      click_on 'Save'

      expect(page).to have_content('Name is missing')
    end
  end
end
