require "rails_helper"

describe "footer partial" do
  scenario "shows access request link with count to admin users" do
    access_requests = mock_access_requests
    user = get_admin_user

    page = render_footer_for user

    expect(page.access_requests_link).to have_text("Access Requests (#{access_requests})")
    expect(page).to have_organisations_link
  end

  scenario "doesn't show access request link to non-admin users" do
    user = get_user

    page = render_footer_for user

    expect(page).not_to have_access_requests_link
    expect(page).not_to have_organisations_link
  end

  def mock_access_requests
    count = 4
    allow(AccessRequest).to receive(:return_count).and_return(count)
    count
  end

  def get_admin_user
    get_user admin: true
  end

  def get_user(admin: false)
    {
      "info" => {
        "first_name" => "bob",
        "last_name" => "bob",
      },
      "admin" => admin,
    }
  end

  def render_footer_for(user)
    render "layouts/footer", current_user: user
    page = PageObjects::Partials::Footer.new
    page.load(rendered)
    page
  end
end
