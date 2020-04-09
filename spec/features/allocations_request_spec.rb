require "rails_helper"

RSpec.feature "PE allocations request" do
  scenario "Accredited body views PE allocations request page for training provider" do
    given_accredited_body_exists
    given_training_provider_exists
    given_i_am_signed_in_as_an_admin

    when_i_visit_pe_alloacations_request_page

    then_i_see_the_pe_alloacations_request_page

    and_i_see_back_link
    and_i_see_training_provider_name
    and_i_see_request_form
  end

  def and_i_see_request_form
    request_form = find '[data-qa="allocation__requested"]'

    expect(request_form.find("#requested_no")).to_not be_checked
    expect(request_form.find("#requested_yes")).to_not be_checked
  end

  def and_i_see_training_provider_name
    expect(find("h1")).to have_content(@training_provider.provider_name)
  end

  def then_i_see_the_pe_alloacations_request_page
    expect(page.title).to have_content("Do you want to request PE for this organisation?")
    expect(find("h1")).to have_content("Do you want to request PE for this organisation?")
  end

  def when_i_visit_pe_alloacations_request_page
    stub_api_v2_resource(@accrediting_body)
    stub_api_v2_resource(@accrediting_body.recruitment_cycle)
    stub_api_v2_resource(@training_provider)

    footer_stub_for_access_request_count

    visit requests_provider_recruitment_cycle_allocation_path(@accrediting_body.provider_code, @accrediting_body.recruitment_cycle.year, @training_provider.provider_code)
  end

  def footer_stub_for_access_request_count
    stub_api_v2_resource_collection([build(:access_request)])
  end

  def given_accredited_body_exists
    @accrediting_body = build(:provider, accredited_body?: true)
  end

  def given_i_am_signed_in_as_an_admin
    stub_omniauth(user: build(:user, :admin))
  end

  def when_i_visit_my_organisations_page
    visit provider_path(@accrediting_body.provider_code)
    expect(find("h1")).to have_content(@accrediting_body.provider_name.to_s)
  end

  def and_i_see_back_link
    expect(page).to have_link(
      "Back",
      href: "/organisations/#{@accrediting_body.provider_code}/2020/allocations",
    )
  end

  def given_training_provider_exists
    @training_provider = build(:provider)
  end
end
