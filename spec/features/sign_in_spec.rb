require 'rails_helper'

RSpec.feature 'Sign in', type: :feature do
  context 'with DfE Sign In' do
    before(:each) do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:dfe] = {
        provider: "dfe",
        uid: "123456789",
        info: {
          first_name: "John",
          last_name: "Smith"
        }
      }
    end

    scenario 'successfully signs the user in and out' do
      visit root_path
      click_link "Sign in"
      expect(page).to have_content("Welcome, John")

      click_link "Sign out (John Smith)"
      expect(page).to have_content("Sign in")
    end
  end
end
