require "rails_helper"

feature "get training_providers", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:organisation_training_providers_page) { PageObjects::Page::Organisations::TrainingProviders.new }
  let(:accrediting_body1) { build :provider, accredited_body?: true }
  let(:accrediting_body2) { build :provider, accredited_body?: true }
  let(:training_provider1) { build :provider, accredited_bodies: [accrediting_body1, accrediting_body2] }
  let(:course1) { build :course, accrediting_provider: accrediting_body1, provider: training_provider1 }
  let(:course2) { build :course, accrediting_provider: accrediting_body2, provider: training_provider1 }
  let(:training_provider2) { build :provider, accredited_bodies: [accrediting_body1] }
  let(:course3) { build :course, accrediting_provider: accrediting_body1, provider: training_provider2 }
  let(:course4) { build :course, accrediting_provider: accrediting_body1, provider: training_provider2 }
  let(:user) { build :user }
  let(:access_request) { build :access_request }

  before do
    signed_in_user(user: user)
    stub_api_v2_resource(accrediting_body1)
    stub_api_v2_resource(accrediting_body1.recruitment_cycle)
    stub_api_v2_request(
      "/recruitment_cycles/#{accrediting_body1.recruitment_cycle.year}/courses" \
      "?filter[accredited_body_code]=#{accrediting_body1.provider_code}",
      resource_list_to_jsonapi([course1, course3, course4]),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{accrediting_body1.recruitment_cycle.year}/providers/" \
      "#{accrediting_body1.provider_code}/training_providers",
      resource_list_to_jsonapi(
        [accrediting_body1, training_provider1, training_provider2],
        meta: {
          accredited_courses_counts: {
            "#{training_provider1.provider_code}": "1",
            "#{training_provider2.provider_code}": "2",
          },
        },
      ),
    )
    stub_api_v2_resource_collection([access_request])
  end

  context "when the provider has training providers" do
    it "can be reached from the provider show page" do
      visit provider_path(accrediting_body1.provider_code)
      organisation_show_page.courses_as_accredited_body_link.click
      expect(current_path).to eq training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)
    end

    it "should have the correct content" do
      visit training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)
      expect(organisation_training_providers_page.title).to have_content("Courses as an accredited body")
      expect(organisation_training_providers_page.training_providers_list).to have_content(training_provider1.provider_name)
      expect(organisation_training_providers_page.training_providers.first.course_count.text).to have_content("1 course")
      expect(organisation_training_providers_page.training_providers_list).to have_content(training_provider2.provider_name)
      expect(organisation_training_providers_page.training_providers.second.course_count.text).to have_content("2 courses")
      expect(organisation_training_providers_page.download_section).to have_link(
        "Download as a CSV file",
        href: download_training_providers_courses_provider_recruitment_cycle_path(
          accrediting_body1.provider_code,
          accrediting_body1.recruitment_cycle.year,
          format: :csv,
        ),
      )
    end

    it "should have the correct breadcrumbs" do
      visit training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)

      within(".govuk-breadcrumbs") do
        expect(page).to have_link(accrediting_body1.provider_name.to_s, href: "/organisations/#{accrediting_body1.provider_code}")
        expect(page).to have_content("Courses as an accredited body")
      end
    end

    it "does not display itself as a training provider" do
      visit training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)

      expect(organisation_training_providers_page.training_providers_list).to_not have_content(accrediting_body1.provider_name)
    end
  end
end
