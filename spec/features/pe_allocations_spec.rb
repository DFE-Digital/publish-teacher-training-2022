require "rails_helper"

RSpec.feature "PE allocations" do
  scenario "Accredited provider views PE allocations page" do
    given_accredited_body_exists
    given_i_am_signed_in

    when_i_visit_my_organisations_page
    and_i_click_request_pe_courses
    then_i_see_the_pe_alloacations_page
  end

  def given_accredited_body_exists
    @accrediting_body = build(:provider, accredited_body?: true)
    stub_api_v2_resource(@accrediting_body.recruitment_cycle)
  end

  def given_i_am_signed_in
    stub_omniauth(user: build(:user))
  end

  def when_i_visit_my_organisations_page
    stub_api_v2_resource(@accrediting_body)
    stub_api_v2_resource_collection([build(:access_request)])

    visit provider_path(@accrediting_body.provider_code)
    expect(find("h1")).to have_content(@accrediting_body.provider_name.to_s)
  end

  def and_i_click_request_pe_courses
    click_on "Request PE courses for 2021/22"
  end

  def then_i_see_the_pe_alloacations_page
    expect(find("h1")).to have_content("Request PE courses for 2021/22")
  end
end
