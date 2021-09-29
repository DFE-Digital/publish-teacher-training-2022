require "rails_helper"

feature "Preview course", type: :feature do
  let(:current_recruitment_cycle) { build :recruitment_cycle }
  let(:course) do
    build(
      :course,
      name: "English",
      provider: provider,
      accrediting_provider: accrediting_provider,
      course_length: "OneYear",
      applications_open_from: "2019-01-01T00:00:00Z",
      start_date: "2019-09-01T00:00:00Z",
      age_range_in_years: "11_to_16",
      fee_uk_eu: "9250.0",
      fee_international: "9250.0",
      fee_details: "Optional fee details",
      has_scholarship_and_bursary?: true,
      financial_support: "Some info about financial support",
      scholarship_amount: "20000",
      bursary_amount: "22000",
      personal_qualities: "We are looking for ambitious trainee teachers who are passionate and enthusiastic about their subject and have a desire to share that with young people of all abilities in this particular age range.",
      other_requirements: "You will need three years of prior work experience, but not necessarily in an educational context.",
      about_accrediting_body: "Something great about the accredited body",
      interview_process: "Some helpful guidance about the interview process",
      how_school_placements_work: "Some info about how teaching placements work",
      about_course: "This is a course",
      required_qualifications: "You need some qualifications for this course",
      has_vacancies?: true,
      recruitment_cycle: current_recruitment_cycle,
      site_statuses: [
        jsonapi_site_status("Running site with vacancies", :full_time, "running"),
        jsonapi_site_status("Suspended site with vacancies", :full_time, "suspended"),
        jsonapi_site_status("New site with vacancies", :full_time, "new_status"),
        jsonapi_site_status("New site with no vacancies", :no_vacancies, "new_status"),
        jsonapi_site_status("Running site with no vacancies", :no_vacancies, "running"),
      ],
      subjects: [subject],
    )
  end

  let(:subject) do
    build(
      :subject,
      :english,
      scholarship: "2000",
      bursary_amount: "4000",
      early_career_payments: "1000",
    )
  end

  let(:provider) do
    build(
      :provider,
      provider_code: "A0",
      website: "https://scitt.org",
      address1: "1 Long Rd",
      postcode: "E1 ABC",
    )
  end
  let(:accrediting_provider) { build(:provider) }
  let(:course_response) do
    course.to_jsonapi(
      include: [
        :sites,
        :provider,
        :accrediting_provider,
        :recruitment_cycle,
        :subjects,
        { site_statuses: :site },
      ],
    )
  end
  let(:decorated_course) { course.decorate }

  before do
    signed_in_user
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(course, include: "subjects,sites,site_statuses.site,provider.sites,accrediting_provider")
    stub_api_v2_resource(provider)
  end

  let(:preview_course_page) { PageObjects::Page::Organisations::CoursePreview.new }

  scenario "viewing the preview course page" do
    visit preview_provider_recruitment_cycle_course_path(provider.provider_code, current_recruitment_cycle.year, course.course_code)

    expect_finanical_support

    expect(preview_course_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )

    expect(preview_course_page.sub_title).to have_content(
      provider.provider_name,
    )

    expect(preview_course_page.accredited_body).to have_content(
      accrediting_provider.provider_name,
    )

    expect(preview_course_page.description).to have_content(
      course.description,
    )

    expect(preview_course_page.qualifications).to have_content(
      "PGCE with QTS",
    )

    expect(preview_course_page.age_range_in_years).to have_content(
      "11 to 16",
    )

    expect(preview_course_page.funding_option).to have_content(
      decorated_course.funding_option,
    )

    expect(preview_course_page.length).to have_content(
      decorated_course.length,
    )

    expect(preview_course_page.applications_open_from).to have_content(
      "1 January 2019",
    )

    expect(preview_course_page.start_date).to have_content(
      "September 2019",
    )

    expect(preview_course_page.provider_website).to have_content(
      provider.website,
    )

    expect(preview_course_page).to_not have_vacancies

    expect(preview_course_page.about_course).to have_content(
      course.about_course,
    )

    expect(preview_course_page.interview_process).to have_content(
      course.interview_process,
    )

    expect(preview_course_page.school_placements).to have_content(
      course.how_school_placements_work,
    )

    expect(preview_course_page).to have_content(
      "The course fees for #{Settings.current_cycle} to #{Settings.current_cycle + 1} are as follows",
    )

    expect(preview_course_page.uk_fees).to have_content(
      "£9,250",
    )

    expect(preview_course_page.international_fees).to have_content(
      "£9,250",
    )

    expect(preview_course_page.fee_details).to have_content(
      decorated_course.fee_details,
    )

    expect(preview_course_page).to_not have_salary_details

    expect(preview_course_page.financial_support_details).to have_content("Financial support from the training provider")

    expect(preview_course_page.required_qualifications).to have_content(
      course.required_qualifications,
    )

    expect(preview_course_page.personal_qualities).to have_content(
      course.personal_qualities,
    )

    expect(preview_course_page.other_requirements).to have_content(
      course.other_requirements,
    )

    expect(preview_course_page.train_with_us).to have_content(
      provider.train_with_us,
    )

    expect(preview_course_page.about_accrediting_body).to have_content(
      course.about_accrediting_body,
    )

    expect(preview_course_page.train_with_disability).to have_content(
      provider.train_with_disability,
    )

    expect(preview_course_page.contact_email).to have_content(
      provider.email,
    )

    expect(preview_course_page.contact_telephone).to have_content(
      provider.telephone,
    )

    expect(preview_course_page.contact_website).to have_content(
      provider.website,
    )

    expect(preview_course_page.contact_address).to have_content(
      "1 Long Rd E1 ABC",
    )

    expect(preview_course_page).to have_choose_a_training_location_table
    expect(preview_course_page.choose_a_training_location_table).not_to have_content("Suspended site with vacancies")

    [
      ["New site with no vacancies", "No"],
      ["New site with vacancies", "Yes"],
      ["Running site with no vacancies", "No"],
      ["Running site with vacancies", "Yes"],
    ].each_with_index do |site, index|
      name, has_vacancies_string = site

      expect(preview_course_page.choose_a_training_location_table)
        .to have_selector("tbody tr:nth-child(#{index + 1}) strong", text: name)

      expect(preview_course_page.choose_a_training_location_table)
        .to have_selector("tbody tr:nth-child(#{index + 1}) td", text: has_vacancies_string)
    end

    expect(preview_course_page).to have_locations_map

    expect(preview_course_page).to have_course_advice
  end

  context "when the provider is in the 2022 recuritment cycle or higher" do
    let(:next_recruitment_cycle) { build :recruitment_cycle, :next_cycle }

    let(:course) do
      build(
        :course,
        provider: provider,
        degree_grade: "two_one",
        degree_subject_requirements: "Maths A level",
        required_qualifications: "You need some qualifications for this course",
        recruitment_cycle: next_recruitment_cycle,
      )
    end

    let(:provider) do
      build(
        :provider,
        recruitment_cycle: next_recruitment_cycle,
        provider_code: "A0",
        website: "https://scitt.org",
        address1: "1 Long Rd",
        postcode: "E1 ABC",
      )
    end

    before do
      signed_in_user
      stub_api_v2_resource(next_recruitment_cycle)
      stub_api_v2_resource(course, include: "subjects,sites,site_statuses.site,provider.sites,accrediting_provider")
      stub_api_v2_resource(provider)
    end

    it "shows the new degree requirements attributes" do
      visit preview_provider_recruitment_cycle_course_path(provider.provider_code, next_recruitment_cycle.year, course.course_code)

      expect(preview_course_page).to have_content "2:1 or above, or equivalent"
      expect(preview_course_page).to have_content "Maths A level"
    end
  end

  context "contact details for London School of Jewish Studies and the course code is X104" do
    let(:provider) do
      build(
        :provider,
        provider_code: "28T",
      )
    end

    let(:course) do
      build(:course,
            course_code: "X104",
            provider: provider)
    end

    it "renders the custom address requested via zendesk" do
      visit preview_provider_recruitment_cycle_course_path(provider.provider_code, current_recruitment_cycle.year, course.course_code)

      expect(preview_course_page).to have_content "LSJS"
      expect(preview_course_page).to have_content "44A Albert Road"
      expect(preview_course_page).to have_content "London"
      expect(preview_course_page).to have_content "NW4 2SJ"
    end
  end

  def jsonapi_site_status(name, study_mode, status)
    build(:site_status, study_mode, site: build(:site, location_name: name), status: status)
  end

  def expect_finanical_support
    # NOTE: There is a period at the beginning of the new/current
    #       recruitment cycle whereby the financial incentives
    #       announcement is still pending.

    financial_incentives_been_announced = true

    if financial_incentives_been_announced
      expect_financial_incentives
    else
      expect_financial_support_placeholder
    end
  end

  def expect_financial_support_placeholder
    expect(decorated_course.use_financial_support_placeholder?).to be_truthy

    expect(preview_course_page.find(".govuk-inset-text"))
      .to have_text("Financial support for 2021 to 2022 will be announced soon. Further information is available on Get Into Teaching.")
    expect(preview_course_page).to_not have_scholarship_amount
    expect(preview_course_page).to_not have_bursary_amount
  end

  def expect_financial_incentives
    expect(decorated_course.use_financial_support_placeholder?).to be_falsey

    expect(preview_course_page.scholarship_amount).to have_content("a scholarship of £2,000")
    expect(preview_course_page.bursary_amount).to have_content("a bursary of £4,000")
  end
end
