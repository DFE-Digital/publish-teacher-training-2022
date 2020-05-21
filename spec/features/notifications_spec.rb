require "rails_helper"

feature "Notifications", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:notifications_index_page) { PageObjects::Page::Notifications::IndexPage.new }

  let(:provider) { build :provider }
  let(:access_request) { build :access_request }
  let(:user) { build :user }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource_collection([access_request])
  end

  context "When the provider is not an accredited body" do
    it "does not have the notifications link" do
      when_i_visit_providers_page
      then_i_should_not_see_notifications_link
    end
  end

  context "When the provider is an accredited body" do
    let(:provider) { build :provider, accredited_body?: true }

    it "organisation page does have the notifications link" do
      when_i_visit_accredited_body_page
      then_i_should_see_notifications_link
    end

    describe "User opting into notifications" do
      it "should allow the user to opt into notifications" do
        when_i_visit_accredited_body_page
        and_i_click_on_notifications_link
        then_the_notifications_page_is_displayed
        and_i_opt_into_notifications
        and_save_my_choice
        then_i_should_see_my_preferences_have_been_saved
      end
    end

    describe "User opting out of notifications" do
      it "should allow the user to opt into notifications" do
        when_i_visit_accredited_body_page
        and_i_click_on_notifications_link
        then_the_notifications_page_is_displayed
        and_i_opt_out_of_notifications
        and_save_my_choice
        then_i_should_see_my_preferences_have_been_saved
      end
    end
  end

private

  def when_i_visit_providers_page
    visit provider_path(provider.provider_code)
  end

  def when_i_visit_accredited_body_page
    when_i_visit_providers_page
  end

  def then_i_should_see_notifications_link
    expect(organisation_show_page).to have_notifications_preference_link
  end

  def then_i_should_not_see_notifications_link
    expect(organisation_show_page).not_to have_notifications_preference_link
  end

  def and_i_click_on_notifications_link
    organisation_show_page.notifications_preference_link.click
  end

  def then_the_notifications_page_is_displayed
    expect(notifications_index_page).to be_displayed
  end

  def and_i_opt_into_notifications
    notifications_index_page.opt_in_radio.click
  end

  def and_i_opt_out_of_notifications
    notifications_index_page.opt_out_radio.click
  end

  def and_save_my_choice
    notifications_index_page.save_button.click
  end

  def then_i_should_see_my_preferences_have_been_saved
    expect(organisation_show_page)
      .to have_content("Your notification preferences have been saved")
  end
end
