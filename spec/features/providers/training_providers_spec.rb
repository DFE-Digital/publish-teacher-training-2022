require "rails_helper"

feature "Get training_providers", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:organisation_training_providers_page) { PageObjects::Page::Organisations::TrainingProviders.new }
  let(:provider1) { build :provider, accredited_body?: true }
  let(:provider2) { build :provider, accredited_bodies: [provider1] }
  let(:provider3) { build :provider, accredited_bodies: [provider1] }
  let(:user) { build :user, :admin }
  let(:access_request) { build :access_request }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(provider1)
    stub_api_v2_resource(provider2)
    stub_api_v2_resource(provider3)
    stub_api_v2_resource(provider1.recruitment_cycle)
    stub_api_v2_request(
      "/recruitment_cycles/#{provider1.recruitment_cycle.year}/providers/" \
      "#{provider1.provider_code}/training_providers?recruitment_cycle_year=#{provider1.recruitment_cycle.year}",
      resource_list_to_jsonapi([provider2, provider3]),
    )
    stub_api_v2_resource_collection([access_request])
  end

  context "When the provider has training providers" do
    context "as an admin user" do
      it "can be reached from the provider show page" do
        visit provider_path(provider1.provider_code)
        organisation_show_page.courses_as_accredited_body_link.click
        expect(current_path).to eq training_providers_provider_recruitment_cycle_path(provider1.provider_code, provider1.recruitment_cycle.year)
      end

      it "should have the correct content" do
        visit training_providers_provider_recruitment_cycle_path(provider1.provider_code, provider1.recruitment_cycle.year)
        expect(organisation_training_providers_page.title).to have_content("Courses as an accredited body")
        expect(organisation_training_providers_page.training_providers_list).to have_content(provider2.provider_name)
        expect(organisation_training_providers_page.training_providers_list).to have_content(provider3.provider_name)
      end

      it "should have the correct breadcrumbs" do
        visit training_providers_provider_recruitment_cycle_path(provider1.provider_code, provider1.recruitment_cycle.year)

        within(".govuk-breadcrumbs") do
          expect(page).to have_link(provider1.provider_name.to_s, href: "/organisations/#{provider1.provider_code}")
          expect(page).to have_content("Courses as an accredited body")
        end
      end
    end

    context "as a non-admin user" do
      let(:user) { build(:user) }

      it "redirects to to the organisation show page" do
        visit training_providers_provider_recruitment_cycle_path(provider1.provider_code, provider1.recruitment_cycle.year)
        expect(current_path).to eq provider_path(provider1.provider_code)
      end
    end
  end
end
