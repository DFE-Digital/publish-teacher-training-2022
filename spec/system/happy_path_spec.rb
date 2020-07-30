require "spec_system_helper"

RSpec.feature "happy path", type: :system do
  let(:login_page) { PageObjects::Page::DFESignIn::LoginPage.new }
  let(:rollover_page) { PageObjects::Page::Rollover.new }
  let(:rollover_recruitment_page) { PageObjects::Page::RolloverRecruitment.new }

  scenario "use is happy" do

    when_i_visit_the_root_path
    then_i_am_redirected_to_dfe_login_page

    when_i_fill_in_my_username_and_password
    when_i_click_sign_in_on_the_login_page
    then_i_am_on_the_rollover_page

    when_i_click_continue_on_the_rollover_page
    then_i_am_on_the_rollover_recruitment_page

    when_i_click_continue_on_the_rollover_recruitment_page

    expect(rollover_recruitment_page).to be_displayed
    rollover_recruitment_page.continue.click

    expect(root_page).to be_displayed
  end

  def when_i_visit_the_root_path
    visit "/"
  end

  def when_i_fill_in_my_username_and_password
    login_page.username.fill_in(with: ENV["DSI_USERNAME"])
    login_page.password.fill_in(with: ENV["DSI_PASSWORD"])
  end

  def when_i_click_sign_in_on_the_login_page
    login_page.sign_in.click
  end

  def when_i_click_continue_on_the_rollover_page
    rollover_page.continue.click
  end

  def when_i_click_continue_on_the_rollover_recruitment_page
    rollover_recruitment_page.continue.click
  end
  def then_i_am_redirected_to_dfe_login_page
    expect(login_page).to be_displayed
  end

  def then_i_am_on_the_rollover_page
    expect(rollover_page).to be_displayed
  end

  def then_i_am_on_the_rollover_recruitment_page
    expect(rollover_recruitment_page).to be_displayed
  end
end
