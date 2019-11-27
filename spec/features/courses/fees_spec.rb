require "rails_helper"

feature "Course fees", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider) { build(:provider, provider_code: "A0") }
  let(:course_1) do
    build :course,
          :with_fees,
          provider: provider,
          recruitment_cycle: current_recruitment_cycle
  end

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(course_1, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(course_1, include: "sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(provider, include: "courses.accrediting_provider")
    stub_api_v2_resource(provider)
  end

  let(:course_fees_page) { PageObjects::Page::Organisations::CourseFees.new }

  scenario "viewing and updating fees" do
    visit provider_recruitment_cycle_course_path(provider.provider_code, course_1.recruitment_cycle_year, course_1.course_code)

    click_on "Course length and fees"

    expect(current_path).to eq fees_provider_recruitment_cycle_course_path("A0", course_1.recruitment_cycle_year, course_1.course_code)

    expect(course_fees_page.caption).to have_content(
      "#{course_1.name} (#{course_1.course_code})",
    )
    expect(course_fees_page.title).to have_content(
      "Course length and fees",
    )
    expect(course_fees_page).to have_enrichment_form
    expect(course_fees_page.course_length_one_year).not_to be_checked
    expect(course_fees_page.course_length_two_years).to be_checked
    expect(course_fees_page.course_length_other_length.value).to eq("")

    expect(course_fees_page.course_fees_uk_eu.value).to have_content(
      course_1.fee_uk_eu,
    )
    expect(course_fees_page.course_fees_international.value).to have_content(
      course_1.fee_international,
    )
    expect(course_fees_page.fee_details).to have_content(
      course_1.fee_details,
    )
    expect(course_fees_page.financial_support).to have_content(
      course_1.financial_support,
    )

    choose "1 year"
    fill_in "Fee for UK and EU students", with: "8,000"
    fill_in "Fee for international students (optional)", with: "16,000"

    fill_in "Fee details (optional)", with: "Test fee details"
    fill_in(
      "Financial support you offer (optional)",
      with: "Test financial support",
    )


    set_fees_request_stub_expectation do |request_attributes|
      expect(request_attributes["course_length"]).to eq("OneYear")
      expect(request_attributes["fee_uk_eu"]).to eq("8000")
      expect(request_attributes["fee_international"]).to eq("16000")
      expect(request_attributes["fee_details"]).to eq("Test fee details")
      expect(request_attributes["financial_support"]).to eq("Test financial support")
    end
    click_on "Save"

    expect(course_fees_page.flash).to have_content(
      "Your changes have been saved",
    )
    expect(current_path).to eq provider_recruitment_cycle_course_path("A0", course_1.recruitment_cycle_year, course_1.course_code)
  end

  scenario "setting length to 'other'" do
    visit fees_provider_recruitment_cycle_course_path("A0", course_1.recruitment_cycle_year, course_1.course_code)
    choose "Other"
    fill_in "Course length", with: "4 years"
    set_fees_request_stub_expectation do |request_attributes|
      expect(request_attributes["course_length"]).to eq("4 years")
    end
    click_on "Save"
    expect(course_fees_page.flash).to have_content("Your changes have been saved")
    expect(current_path).to eq provider_recruitment_cycle_course_path("A0", course_1.recruitment_cycle_year, course_1.course_code)
  end

  scenario "submitting with validation errors" do
    stub_api_v2_request(
      "/recruitment_cycles/#{course_1.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course_1.course_code}",
      build(:error, :for_course_publish),
      :patch, 422
    )

    visit fees_provider_recruitment_cycle_course_path(provider.provider_code, course_1.recruitment_cycle_year, course_1.course_code)

    fill_in "Fee for UK and EU students", with: 100_000_000
    click_on "Save"

    expect(course_fees_page.error_flash).to have_content(
      "You’ll need to correct some information.",
    )
    expect(current_path).to eq fees_provider_recruitment_cycle_course_path(provider.provider_code, course_1.recruitment_cycle_year, course_1.course_code)
  end

  context "with course_length_other selected" do
    let(:course_1) do
      build :course,
            :with_fees,
            course_length: "6 months",
            provider: provider,
            recruitment_cycle: current_recruitment_cycle
    end

    scenario "passes the value into course_length" do
      visit provider_recruitment_cycle_course_path(provider.provider_code, course_1.recruitment_cycle_year, course_1.course_code)

      click_on "Course length and fees"

      expect(current_path).to eq fees_provider_recruitment_cycle_course_path("A0", course_1.recruitment_cycle_year, course_1.course_code)

      expect(course_fees_page.course_length_other).to be_checked
      expect(course_fees_page.course_length_other_length.value).to eq("6 months")
    end
  end

  context "when copying course fees from another course" do
    let(:course_2) {
      build :course,
            name: "Biology",
            provider: provider,
            course_length: "Something custom",
            fee_uk_eu: 9500,
            fee_international: 1200,
            fee_details: "Some information about the fees",
            financial_support: "Some information about the finance support",
            recruitment_cycle: current_recruitment_cycle
    }

    let(:course_3) {
      build :course,
            name: "Biology",
            provider: provider,
            fee_details: "Course 3 has just fee details",
            financial_support: "and financial support (Course 3)",
            recruitment_cycle: current_recruitment_cycle
    }

    let(:provider_for_copy_from_list) do
      build(:provider, courses: [course_1, course_2, course_3], provider_code: "A0")
    end

    before do
      stub_api_v2_resource(course_2, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_2, include: "sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_3, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_3, include: "sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(provider_for_copy_from_list, include: "courses.accrediting_provider")
    end

    scenario "all fields get copied if all were present" do
      course_fees_page.load_with_course(course_1)
      course_fees_page.copy_content.copy(course_2)

      [
        "Your changes are not yet saved",
        "Course length",
        "Fee details",
        "Financial support",
      ].each do |name|
        expect(course_fees_page.warning_message).to have_content(name)
      end

      expect(course_fees_page.course_length_one_year).to_not be_checked
      expect(course_fees_page.course_length_two_years).to_not be_checked
      expect(course_fees_page.course_length_other).to be_checked
      expect(course_fees_page.course_length_other_length.value).to eq("Something custom")
      expect(course_fees_page.course_fees_uk_eu.value).to eq(course_2.fee_uk_eu.to_s)
      expect(course_fees_page.course_fees_international.value).to eq(course_2.fee_international.to_s)
      expect(course_fees_page.fee_details.value).to eq(course_2.fee_details)
      expect(course_fees_page.financial_support.value).to eq(course_2.financial_support)
    end

    scenario "only fields with values are copied if the source was incomplete" do
      course_fees_page.load_with_course(course_2)
      course_fees_page.copy_content.copy(course_3)

      [
        "Your changes are not yet saved",
        "Fee details",
        "Financial support",
      ].each do |name|
        expect(course_fees_page.warning_message).to have_content(name)
      end

      [
        "Course length",
      ].each do |name|
        expect(course_fees_page.warning_message).not_to have_content(name)
      end

      expect(course_fees_page.course_length_one_year).to_not be_checked
      expect(course_fees_page.course_length_two_years).to_not be_checked
      expect(course_fees_page.course_length_other).to be_checked
      expect(course_fees_page.course_length_other_length.value).to eq("Something custom")
      expect(course_fees_page.course_fees_uk_eu.value).to eq(course_2.fee_uk_eu.to_s)
      expect(course_fees_page.course_fees_international.value).to eq(course_2.fee_international.to_s)
      expect(course_fees_page.fee_details.value).to eq(course_3.fee_details)
      expect(course_fees_page.financial_support.value).to eq(course_3.financial_support)
    end
  end

private

  def set_fees_request_stub_expectation(&attribute_validator)
    stub_api_v2_resource(course_1, method: :patch) do |request_body_json|
      request_attributes = request_body_json["data"]["attributes"]
      attribute_validator.call(request_attributes)
    end
  end
end
