require "rails_helper"

feature "View provider about", type: :feature do
  let(:org_about_page) { PageObjects::Page::Organisations::OrganisationAbout.new }
  let(:org_details_page) { PageObjects::Page::Organisations::OrganisationDetails.new }
  let(:accredited_bodies) do
    [
      { "provider_name": "Baz", "provider_code" => "Z01" },
      { "provider_name": "Qux", "provider_code" => "Z02" },
    ]
  end
  let(:provider) do
    build :provider,
          provider_code: "A0",
          content_status: "published",
          accredited_bodies: accredited_bodies
  end

  before do
    allow(Settings.features.rollover).to receive(:can_edit_current_and_next_cycles).and_return(false)
    signed_in_user

    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}",
      provider.recruitment_cycle.to_jsonapi,
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      provider.to_jsonapi,
    )
  end

  let(:provider_params) do
    {
      "page" => "about",
      "train_with_us" => "Foo",
      "train_with_disability" => "Bar",
      "accredited_bodies" => [
        { "provider_name": "Baz", "provider_code" => accredited_bodies[0]["provider_code"], "description" => "Baz" },
        { "provider_name": "Qux", "provider_code" => accredited_bodies[1]["provider_code"], "description" => "Qux" },
      ],
    }
  end

  scenario "viewing organisation about page" do
    visit about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(current_path).to eq about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(org_about_page.title).to have_content("About your organisation")

    expect(org_about_page.train_with_us.value).to eq(provider.train_with_us)
    expect(org_about_page.train_with_disability.value).to eq(provider.train_with_disability)
  end

  scenario "submitting successfully" do
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      "",
      :patch,
      200,
    ).with(body: {
      data: {
        provider_code: provider.provider_code,
        type: "providers",
        attributes: provider_params,
      },
    }.to_json)

    visit about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)

    fill_in "provider[train_with_us]", with: "Foo"
    fill_in "provider[train_with_disability]", with: "Bar"
    fill_in "provider-accredited-bodies-attributes-0-description-field", with: "Baz"
    fill_in "provider-accredited-bodies-attributes-1-description-field", with: "Qux"
    click_on "Save"

    expect(org_details_page.flash).to have_content(
      "Your changes have been published",
    )
    expect(current_path).to eq details_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  scenario "submitting with validation errors" do
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      build(:error, :for_provider_update),
      :patch,
      422,
    )

    visit about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)

    fill_in "provider[train_with_us]", with: "foo " * 401
    click_on "Save"

    expect(org_about_page.error_flash).to have_content(
      "There is a problem",
    )
    expect(current_path).to eq about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
