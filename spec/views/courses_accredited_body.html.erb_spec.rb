require "rails_helper"

RSpec.shared_examples "accredited_body_partial_shown" do |accredited:, admin:, expected:|
  scenario do
    user = get_user admin: admin
    mock_provider accredited: accredited

    page = render_page_for user

    if expected
      expect(page).to have_courses_as_accredited_body_link
    else
      expect(page).not_to have_courses_as_accredited_body_link
    end
  end
end

describe "courses accredited body partial" do
  include_examples "accredited_body_partial_shown", accredited: true,  admin: true,  expected: true
  include_examples "accredited_body_partial_shown", accredited: true,  admin: false, expected: false
  include_examples "accredited_body_partial_shown", accredited: false, admin: true,  expected: false
  include_examples "accredited_body_partial_shown", accredited: false, admin: false, expected: false
end

def get_user(admin: false)
  {
      "admin" => admin,
  }
end

def mock_provider(accredited:)
  provider = build(:provider, accredited_body?: accredited)
  assign(:provider, provider)
end

def render_page_for(user)
  render "recruitment_cycles/courses_accredited_body", current_user: user, year: 2020
  page = PageObjects::Partials::CoursesAccreditedBody.new
  page.load(rendered)
  page
end
