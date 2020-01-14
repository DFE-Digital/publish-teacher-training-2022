require "rails_helper"

feature "Course details", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:next_recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }
  let(:provider) { build(:provider, provider_code: "A0", accredited_body?: false, sites: [site1, site2], recruitment_cycle: current_recruitment_cycle) }
  let(:study_mode) { "full_time" }
  let(:level) { :secondary }
  let(:course) do
    build(:course,
          study_mode: study_mode,
          level: level,
          start_date: Time.zone.local(2019),
          sites: [site1, site2],
          provider: provider,
          accrediting_provider: provider,
          open_for_applications?: true,
          age_range_in_years: "3_to_7",
          recruitment_cycle: current_recruitment_cycle)
  end
  let(:site1) { build(:site, location_name: "London") }
  let(:site2) { build(:site, location_name: "Manchester") }
  let(:site_status1) do
    build(:site_status, :full_time, site: site1, status: "running")
  end
  let(:site_status2) do
    build(:site_status, :part_time, site: site2, status: "suspended")
  end

  before do
    stub_omniauth
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(next_recruitment_cycle)
    stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
    stub_api_v2_resource(provider)
  end

  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }

  scenario "viewing the course details page" do
    visit "/organisations/A0/#{course.recruitment_cycle.year}/courses/#{course.course_code}/details"

    expect(course_details_page)
      .to be_displayed(provider_code: provider.provider_code, course_code: course.course_code)

    expect(course_details_page.caption).to have_content(
      course.description,
    )
    expect(course_details_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(course_details_page.subjects).to have_content(
      course.subjects.sort.join("").to_s,
    )
    expect(course_details_page.age_range).to have_content(
      "3 to 7",
    )
    expect(course_details_page.edit_age_range_link).to have_content(
      "Change age range",
    )

    expect(course_details_page.qualifications).to have_content(
      "PGCE with QTS",
    )
    expect(course_details_page.study_mode).to have_content(
      "Full time",
    )
    expect(course_details_page.start_date).to have_content(
      "January 2019",
    )
    expect(course_details_page.name).to have_content(
      course.name,
    )
    expect(course_details_page.description).to have_content(
      course.description,
    )
    expect(course_details_page.course_code).to have_content(
      course.course_code,
    )
    expect(course_details_page.locations).to have_content(
      site1.location_name,
    )
    expect(course_details_page.locations).to have_content(
      site2.location_name,
    )
    expect(course_details_page.edit_locations_link).to have_content(
      "Change location",
    )
    expect(course_details_page).to have_no_manage_provider_locations_link
    expect(course_details_page).to have_no_apprenticeship
    expect(course_details_page.funding).to have_content(
      "Fee paying (no salary)",
    )
    expect(course_details_page.accredited_body).to have_content(
      provider.provider_name,
    )
    expect(course_details_page.is_send).to have_content(
      "No",
    )
    expect(course_details_page.level).to have_content(
      "Secondary",
    )
    expect(course_details_page).to have_entry_requirements
  end

  context "When the course has nil fields" do
    let(:study_mode) { nil }
    let(:level) { nil }

    scenario "It shows blank for nil fields" do
      visit "/organisations/A0/#{course.recruitment_cycle.year}/courses/#{course.course_code}/details"

      expect(course_details_page.study_mode.text).to be_blank
      expect(course_details_page.level.text).to be_blank
    end
  end

  context "a course without required GCSE subjects" do
    let(:course) do
      build(
        :course,
        provider: provider,
        gcse_subjects_required: [],
      )
    end

    scenario "has no entry requirements" do
      course_details_page.load_with_course(course)
      expect(course_details_page).not_to have_entry_requirements
    end
  end

  context "a course with required GCSE subjects" do
    let(:course) do
      build(
        :course,
        provider: provider,
        gcse_subjects_required: %w[maths science],
        english: "expect_to_achieve_before_training_begins",
        science: "equivalency_test",
        age_range_in_years: nil,
      )
    end

    scenario "shows entry requirements" do
      course_details_page.load_with_course(course)
      expect(course_details_page).to have_entry_requirements
      expect(course_details_page.entry_requirements).to have_content("Maths GCSE: Taking")
      expect(course_details_page.entry_requirements).to have_content("Science GCSE: Equivalency test")
      expect(course_details_page.entry_requirements).not_to have_content("English GCSE")
      expect(course_details_page.age_range).to have_content("Unknown")
    end
  end

  context "the course is further education" do
    let(:course) do
      build(
        :course,
        provider: provider,
        level: "further_education",
      )
    end

    scenario "viewing the course details page does not show age range" do
      course_details_page.load_with_course(course)
      expect(course_details_page).not_to have_age_range
    end
  end

  context "when the course is new and not running" do
    let(:course) do
      build :course,
            sites: [site1, site2],
            provider: provider,
            ucas_status: "new",
            recruitment_cycle: current_recruitment_cycle
    end

    scenario "viewing the course details page" do
      visit "/organisations/A0/#{course.recruitment_cycle.year}/courses/#{course.course_code}/details"

      expect(course_details_page.locations).to have_content(
        site1.location_name,
      )
      expect(course_details_page.locations).to have_content(
        site2.location_name,
      )
    end
  end

  scenario "viewing the show page for a course that does not exist" do
    stub_api_v2_request(
      "/recruitment_cycles/#{Settings.current_cycle}/providers/ZZ/courses/ZZZ?include=subjects,sites,provider.sites,accrediting_provider",
      "",
      :get,
      404,
    )

    course
    visit "/organisations/ZZ/#{Settings.current_cycle}/courses/ZZZ/details"

    expect(course_details_page)
    .to be_displayed(provider_code: "ZZ", course_code: "ZZZ")
    expect(course_details_page.title.text).to eq "Page not found"
  end

  describe "allocations" do
    let(:course) do
      build(:course,
            provider: provider,
            recruitment_cycle: next_recruitment_cycle)
    end

    context "when the course is in the next recruitment cycle" do
      let(:current_recruitment_cycle) { next_recruitment_cycle }

      scenario "displays no restrictions" do
        course_details_page.load_with_course(course)
        expect(course_details_page.allocations_info).to have_content(
          "Recruitment is not restricted",
        )
      end

      context "when the course is Physical Education" do
        let(:course) do
          build :course,
                provider: provider,
                recruitment_cycle: next_recruitment_cycle,
                subjects: [build(:subject, subject_name: "Biology"), build(:subject, subject_name: "Physical education")]
        end

        scenario "displays no restrictions" do
          course_details_page.load_with_course(course)
          expect(course_details_page.allocations_info).to have_content(
            "Recruitment to fee-funded PE courses is limited by the number of places allocated to you by DfE.",
          )
        end
      end
    end

    context "when the course is in the current recruitment cycle" do
      let(:course) do
        build(:course,
              provider: provider,
              recruitment_cycle: current_recruitment_cycle)
      end

      scenario "displays no restrictions" do
        course_details_page.load_with_course(course)
        expect(course_details_page).to_not have_allocations_info
      end
    end
  end

  context "displays allocation restrictions" do
    let(:provider) { build(:provider, provider_code: "A0", accredited_body?: false, sites: [site1, site2], recruitment_cycle: next_recruitment_cycle) }

    let(:course) do
      build(:course,
            provider: provider,
            recruitment_cycle: next_recruitment_cycle)
    end

    scenario "displays no restrictions" do
      course_details_page.load_with_course(course)
      expect(course_details_page.allocations_info).to have_content(
        "Recruitment is not restricted",
      )
    end
  end

  context "an unpublished course" do
    context "a self accredited course" do
      let(:course) { build(:course, accrediting_provider: nil, content_status: "draft", provider: provider, accredited_body: true) }
      let(:provider) { build(:provider, accredited_body?: true) }
      scenario "displays a link to edit apprenticeship" do
        course_details_page.load_with_course(course)
        expect(course_details_page).to have_edit_apprenticeship_link
      end
    end

    context "an externally accredited course" do
      let(:course) { build(:course, content_status: "draft", provider: provider) }
      scenario "displays a link to edit funding type" do
        course_details_page.load_with_course(course)
        expect(course_details_page).to have_edit_funding_link
      end
    end
  end
end
