require "rails_helper"

id_selector = ->(code) { "course_accrediting_provider_code_#{code.downcase}" }
for_selector = ->(code) { "[for=\"#{id_selector.(code)}\"]" }

feature "Edit accredited body", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:accredited_body_search) { PageObjects::Page::Organisations::CourseAccreditedBodySearch.new }
  let(:accredited_body_page) { PageObjects::Page::Organisations::CourseAccreditedBody.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:accrediting_provider_1) { build(:provider) }
  let(:accrediting_provider_2) { build(:provider) }
  let(:accredited_bodies) {
    [
      { "provider_name": accrediting_provider_1.provider_name, "provider_code" => accrediting_provider_1.provider_code },
      { "provider_name": accrediting_provider_2.provider_name, "provider_code" => accrediting_provider_2.provider_code },
    ]
  }

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(course)
    stub_api_v2_resource(course, include: "accrediting_provider")
    stub_api_v2_resource(course, include: "sites,provider.sites,accrediting_provider")

    accredited_body_page.load_with_course(course)
  end

  context "a course with no accredited body" do
    let(:provider) { build(:provider) }
    let(:course) { build(:course, provider: provider, content_status: "draft") }

    scenario "can cancel changes" do
      click_on "Cancel changes"
      expect(course_details_page).to be_displayed
    end

    scenario "can navigate to the edit screen and back again" do
      course_details_page.load_with_course(course)
      click_on "Change accredited body"
      expect(accredited_body_page).to be_displayed
      click_on "Back"
      expect(course_details_page).to be_displayed
    end

    scenario "can search for an accredited body" do
      searching_returns_some_results
      fill_in "Name of accredited body", with: "ACME"
      click_on "Save and publish changes"
      expect(accredited_body_search).to be_displayed
    end
  end

  context "a course with accredited bodies" do
    let(:provider) { build(:provider, accredited_bodies: accredited_bodies) }
    let(:course) do
      build(
        :course,
        provider: provider,
        accrediting_provider: accrediting_provider_2,
      )
    end

    scenario "presents a choice for each accrediting body" do
      expect(accredited_body_page).to have_accredited_body_fields
      expect(accredited_body_page.accredited_body_fields)
        .to have_selector(
          for_selector.(accrediting_provider_1.provider_code),
          text: accrediting_provider_1.provider_name,
        )
      expect(accredited_body_page.accredited_body_fields)
        .to have_selector(
          for_selector.(accrediting_provider_2.provider_code),
          text: accrediting_provider_2.provider_name,
        )
    end

    scenario "presents the option to choose another accrediting body" do
      expect(accredited_body_page).to have_content("A new accredited body you’re working with")
      expect(accredited_body_page).to have_content("Name of accredited body")
    end

    context "accrediting body search" do
      context "with some results" do
        before do
          searching_returns_some_results
          choose "A new accredited body you’re working with"
          fill_in "Name of accredited body", with: "ACME"
          click_on "Save and publish changes"
        end

        scenario "goes to search page when a partial accrediting body is specified" do
          expect(accredited_body_search).to be_displayed
        end

        scenario "shows all providers from a search" do
          expect(accredited_body_search.accredited_body_options.length).to eq(4)
        end
      end

      context "with no results" do
        before do
          searching_returns_no_results
          choose "A new accredited body you’re working with"
          fill_in "Name of accredited body", with: "ACME"
          click_on "Save and publish changes"
        end

        scenario "goes to search page when a partial accrediting body is specified" do
          expect(accredited_body_search).to be_displayed
        end

        scenario "says no providers were found" do
          expect(accredited_body_search).to have_content("We did not find any")
        end

        scenario "shows no providers" do
          expect(accredited_body_search.accredited_body_options.length).to eq(0)
        end
      end
    end

    scenario "has the correct value selected" do
      expect(accredited_body_page.accredited_body_fields)
        .to have_field(
          id_selector.(accrediting_provider_2.provider_code),
          checked: true,
        )
    end

    scenario "can be updated" do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      ).with(body: {
        data: {
          course_code: course.course_code,
          type: "courses",
          attributes: {
            accrediting_provider_code: accrediting_provider_1.provider_code,
          },
        },
      }.to_json)

      choose accrediting_provider_1.provider_name
      click_on "Save and publish changes"

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content("Your changes have been saved")
      expect(update_course_stub).to have_been_requested
    end

    context "validations" do
      context "choosing" do
        let(:course) { build(:course, provider: provider) }

        scenario "shows error when no option is chosen" do
          click_on "Save and publish changes"

          expect(accredited_body_page).to be_displayed
          expect(accredited_body_page).to have_content("Pick an accredited body")
        end
      end

      context "searching" do
        before do
          choose "A new accredited body you’re working with"
        end

        scenario "shows error when query is empty or too short" do
          fill_in "Name of accredited body", with: ""
          click_on "Save and publish changes"

          expect(accredited_body_page).to be_displayed
          expect(accredited_body_page).to have_content("search too short")

          fill_in "Name of accredited body", with: "AT"
          click_on "Save and publish changes"

          expect(accredited_body_page).to be_displayed
          expect(accredited_body_page).to have_content("search too short")
        end
      end
    end
  end

  def searching_returns_some_results
    stub_api_v2_request(
      "/providers/suggest?query=ACME",
      resource_list_to_jsonapi([
        build(:provider_suggestion, provider_name: "ACME 1", provider_code: "A01"),
        build(:provider_suggestion, provider_name: "ACME 2"),
        build(:provider_suggestion, provider_name: "ACME 3"),
        build(:provider_suggestion, provider_name: "ACME 4"),
      ]),
    )
  end

  def searching_returns_no_results
    stub_api_v2_request(
      "/providers/suggest?query=ACME",
      resource_list_to_jsonapi([]),
    )
  end
end
