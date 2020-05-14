require "rails_helper"

feature "Provider users page" do
  let(:provider_users_page) { PageObjects::Page::Providers::Users::IndexPage.new }
  let(:new_access_request_page) { PageObjects::Page::Organisations::NewManualAccessRequestPage.new }

  let(:current_recruitment_cycle) { build(:recruitment_cycle) }

  scenario "View a provider's user page" do
    given_a_provider_exists
    given_i_am_signed_in_as_a_provider_user

    when_i_visit_the_providers_user_page

    then_i_see_the_provider_users_page
    and_i_see_the_users_details

    when_i_click_on_request_access

    then_i_see_the_request_access_form
  end

  def given_a_provider_exists
    @user = build(:user)
    @provider = build(:provider, users: [@user])
  end

  def given_i_am_signed_in_as_a_provider_user
    stub_api_v2_resource(@provider.recruitment_cycle)
    stub_omniauth(user: @user)
  end

  def when_i_visit_the_providers_user_page
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{@provider.provider_code}?include=users",
      @provider.to_jsonapi(include: %i[users]),
    )

    visit "/organisations/#{@provider.provider_code}/users"
  end

  def then_i_see_the_provider_users_page
    expect(provider_users_page.heading).to have_content("Users")
  end

  def and_i_see_the_users_details
    expect(provider_users_page.user_name).to have_content((@user.first_name @user.last_name).to_s)
  end

  def when_i_click_on_request_access
    click_on("Invite user")
  end

  def then_i_see_the_request_access_form
    expect(page.current_path).to eq("/organisations/#{@provider.provider_code}/request-access")
  end
end
