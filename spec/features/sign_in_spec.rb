require 'rails_helper'

RSpec.feature 'Sign in', type: :feature do
  scenario 'using DfE Sign-in' do
    stub_omniauth
    visit root_path
    expect(page).to have_link("Sign in")
    click_link "Sign in"
    expect(page).to have_content("Welcome, John")
    expect(page).to have_content("Sign out (John Smith)")
  end
end
