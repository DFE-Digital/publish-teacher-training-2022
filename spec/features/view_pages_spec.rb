require "rails_helper"

feature "View pages", type: :feature do
  let(:new_features_page) { PageObjects::Page::NewFeaturesPage.new }

  scenario "Environment label and class are read from settings" do
    visit "/cookies"
    expect(find(".app-tag--#{Settings.environment.selector_name}")).to have_content(Settings.environment.label)
    expect(page).to have_selector(".app-header--#{Settings.environment.selector_name}")
  end

  scenario "Navigate to /cookies" do
    visit "/cookies"
    expect(find("h1")).to have_content("Cookies")
  end

  scenario "Navigate to /terms-conditions" do
    visit "/terms-conditions"
    expect(find("h1")).to have_content("Terms and conditions")
  end

  scenario "Navigate to /privacy-policy" do
    visit "/privacy-policy"
    expect(find("h1")).to have_content("Privacy policy")
  end

  scenario "Navigate to /guidance" do
    visit "/guidance"
    expect(find("h1")).to have_content("Guidance for Publish teacher training courses")
  end

  scenario "Navigate to /accessibility" do
    visit accessibility_path
    expect(find("h1")).to have_content("Accessibility statement for Publish teacher training courses")
  end
end
