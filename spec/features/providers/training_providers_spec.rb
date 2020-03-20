require "rails_helper"

feature "Get training_providers", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:organisation_training_providers_page) { PageObjects::Page::Organisations::TrainingProviders.new }
  let(:accrediting_body1) { build :provider, accredited_body?: true }
  let(:accrediting_body2) { build :provider, accredited_body?: true }
  let(:course1) { build :course, accrediting_provider: accrediting_body1 }
  let(:course2) { build :course, accrediting_provider: accrediting_body2 }
  let(:training_provider1) { build :provider, accredited_bodies: [accrediting_body1, accrediting_body2], courses: [course1, course2] }
  let(:course3) { build :course, accrediting_provider: accrediting_body1 }
  let(:course4) { build :course, accrediting_provider: accrediting_body1 }
  let(:training_provider2) { build :provider, accredited_bodies: [accrediting_body1], courses: [course3, course4] }
  let(:user) { build :user, :admin }
  let(:access_request) { build :access_request }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(accrediting_body1)
    stub_api_v2_resource(accrediting_body1.recruitment_cycle)
    stub_api_v2_request(
      "/recruitment_cycles/#{accrediting_body1.recruitment_cycle.year}/providers/" \
      "#{accrediting_body1.provider_code}/training_providers?recruitment_cycle_year=#{accrediting_body1.recruitment_cycle.year}",
      resource_list_to_jsonapi([training_provider1, training_provider2]),
    )
    stub_api_v2_resource_collection([access_request])
    stub_api_v2_request(
      "/recruitment_cycles/#{training_provider1.recruitment_cycle.year}/providers/" \
      "#{training_provider1.provider_code}?include=courses.accrediting_provider",
      training_provider1.to_jsonapi(include: :courses),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{training_provider2.recruitment_cycle.year}/providers/" \
      "#{training_provider2.provider_code}?include=courses.accrediting_provider",
      training_provider2.to_jsonapi(include: :courses),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{accrediting_body1.recruitment_cycle.year}/providers/" \
      "#{accrediting_body1.provider_code}?include=courses.accrediting_provider",
      accrediting_body1.to_jsonapi(include: :courses),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{accrediting_body2.recruitment_cycle.year}/providers/" \
      "#{accrediting_body2.provider_code}?include=courses.accrediting_provider",
      accrediting_body2.to_jsonapi(include: :courses),
    )
  end

  context "When the provider has training providers" do
    context "as an admin user" do
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
      end

      it "should have the correct breadcrumbs" do
        visit training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)

        within(".govuk-breadcrumbs") do
          expect(page).to have_link(accrediting_body1.provider_name.to_s, href: "/organisations/#{accrediting_body1.provider_code}")
          expect(page).to have_content("Courses as an accredited body")
        end
      end
    end

    context "as a non-admin user" do
      let(:user) { build(:user) }

      it "redirects to to the organisation show page" do
        visit training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)
        expect(current_path).to eq provider_path(accrediting_body1.provider_code)
      end
    end
  end
end
