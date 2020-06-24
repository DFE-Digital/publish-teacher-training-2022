require "rails_helper"

describe "header partial" do
  scenario "shows notifications preference link to users who are an accredited body" do
    user = get_user_with_accredited_body

    page = render_header_for(user)

    expect(page).to have_notifications_preference_link
  end

  scenario "doesn't show notifications preference link to users who aren't an accredited body" do
    user = get_user

    page = render_header_for(user)

    expect(page).to_not have_notifications_preference_link
  end
end

def get_user_with_accredited_body
  get_user(with_accredited_body: true)
end

def get_user(with_accredited_body: false)
  {
    "info" => {
      "first_name" => "bob",
      "last_name" => "bob",
    },
    "associated_with_accredited_body" => with_accredited_body,
  }
end

def render_header_for(user)
  render "layouts/header", current_user: user
  page = PageObjects::Partials::Header.new
  page.load(rendered)
  page
end
