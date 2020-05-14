require "rails_helper"

feature "Course show", type: :feature do
  let(:provider) do
    build(
      :provider,
      accredited_body?: false,
      provider_name: "ACME SCITT A0",
      provider_code: "A0",
    )
  end

  let(:rolled_over_provider) do
    build(
      :provider,
      recruitment_cycle: next_recruitment_cycle,
      accredited_body?: false,
      provider_name: "ACME SCITT A0",
      provider_code: "A0",
    )
  end

  let(:current_recruitment_cycle) { build :recruitment_cycle }
  let(:next_recruitment_cycle) { build :recruitment_cycle, :next_cycle }
  let(:course) do
    build(
      :course,
      :with_fees,
      has_vacancies?: true,
      course_code: "C1",
      open_for_applications?: true,
      funding_type: "fee",
      fee_uk_eu: 9250,
      last_published_at: "2019-03-05T14:42:34Z",
      provider: provider,
      provider_code: provider.provider_code,
      recruitment_cycle: current_recruitment_cycle,
      site_statuses: [site_status],
      about_course: "Foo",
      interview_process: "Foo",
      how_school_placements_work: "Foo",
      required_qualifications: "Foo",
      personal_qualities: "Foo",
      other_requirements: "Foo",
      sites: [site],
    )
  end
  let(:site) { build :site, code: "Z" }
  let(:site_status) do
    build(
      :site_status,
      :full_time_and_part_time,
      site: site,
    )
  end

  let(:course_response) do
    course.to_jsonapi(
      include: %i[subjects sites provider accrediting_provider recruitment_cycle],
    )
  end

  before do
    stub_omniauth

    stub_api_v2_resource current_recruitment_cycle
    stub_api_v2_resource next_recruitment_cycle
    stub_api_v2_resource course,
                         include: "subjects,sites,provider.sites,accrediting_provider"
    stub_api_v2_resource(provider)
    stub_api_v2_resource(rolled_over_provider)

    visit provider_recruitment_cycle_course_path(
      course.provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  let(:course_page) { PageObjects::Page::Organisations::Course.new }
  let(:about_course_page) { PageObjects::Page::Organisations::CourseAbout.new }

  describe "with a fee paying course" do
    scenario "it shows the course show page" do
      expect(course_page.caption).to have_content(
        course.description,
      )
      expect(course_page.title).to have_content(
        "#{course.name} (#{course.course_code})",
      )
      expect(course_page.about).to have_content(
        course.about_course,
      )
      expect(course_page.interview_process).to have_content(
        course.interview_process,
      )
      expect(course_page.placements_info).to have_content(
        course.how_school_placements_work,
      )
      expect(course_page.length).to have_content(
        "Up to 2 years",
      )
      expect(course_page.uk_fees).to have_content(
        "£9,250",
      )
      expect(course_page.international_fees).to have_content(
        "£14,000",
      )
      expect(course_page.fee_details).to have_content(
        course.fee_details,
      )
      expect(course_page.required_qualifications).to have_content(
        course.required_qualifications,
      )
      expect(course_page.personal_qualities).to have_content(
        course.personal_qualities,
      )
      expect(course_page.other_requirements).to have_content(
        course.other_requirements,
      )
      expect(course_page.last_published_at).to have_content(
        "Last published: 5 March 2019",
      )
      expect(course_page).to_not have_preview_link

      expect(course_page).to have_link(
        "About this course",
        href: "/organisations/#{provider.provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}/about",
      )
      expect(course_page).to have_link(
        "Course length and fees",
        href: "/organisations/#{provider.provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}/fees",
      )
      expect(course_page).to have_link(
        "Requirements and eligibility",
        href: "/organisations/#{provider.provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}/requirements",
      )
    end
  end

  describe "with a salaried course" do
    let(:course) do
      build(
        :course,
        :with_fees,
        funding_type: "salary",
        sites: [site],
        provider: provider,
        accrediting_provider: provider,
        about_course: "Foo",
        interview_process: "Foo",
        how_school_placements_work: "Foo",
        required_qualifications: "Foo",
        personal_qualities: "Foo",
        salary_details: "Foo",
        other_requirements: "Foo",
      )
    end

    scenario "it shows the course show page" do
      expect(course_page.caption).to have_content(
        course.description,
      )
      expect(course_page.title).to have_content(
        "#{course.name} (#{course.course_code})",
      )
      expect(course_page.about).to have_content(
        course.about_course,
      )
      expect(course_page.interview_process).to have_content(
        course.interview_process,
      )
      expect(course_page.placements_info).to have_content(
        course.how_school_placements_work,
      )
      expect(course_page.length).to have_content(
        "Up to 2 years",
      )
      expect(course_page.salary).to have_content(
        course.salary_details,
      )
      expect(course_page.required_qualifications).to have_content(
        course.required_qualifications,
      )
      expect(course_page.personal_qualities).to have_content(
        course.personal_qualities,
      )
      expect(course_page.other_requirements).to have_content(
        course.other_requirements,
      )
      expect(course_page).to_not have_preview_link
    end
  end

  context "when the course is running" do
    let(:course) do
      build :course,
            findable?: true,
            content_status: "published",
            ucas_status: "running",
            has_vacancies?: true,
            open_for_applications?: true,
            provider: provider
    end

    scenario "it displays a status panel" do
      expect(course_page).to have_status_panel
      expect(course_page.is_findable).to have_content("Yes")
      expect(course_page.has_vacancies).to have_content("Yes")
      expect(course_page.open_for_applications).to have_content("Open")
      expect(course_page.status_tag).to have_content("Published")
    end
  end

  context "when the course has been rolled over" do
    let(:course) do
      build(
        :course,
        recruitment_cycle: next_recruitment_cycle,
        findable?: false,
        content_status: "rolled_over",
        ucas_status: "new",
        has_vacancies?: true,
        open_for_applications?: false,
        provider: rolled_over_provider,
      )
    end

    scenario "it displays a status panel" do
      expect(course_page).to have_status_panel
      expect(course_page.is_findable).to have_content("No")
      expect(course_page.status_tag).to have_content("Rolled over")
      expect(course_page.publish.value).to eq "Publish in October"
    end
  end

  context "when the course is withdrawn" do
    let(:course) do
      build(
        :course,
        findable?: false,
        content_status: "withdrawn",
        ucas_status: "not_running",
        provider: provider,
      )
    end

    scenario "it displays a status panel" do
      expect(course_page).to have_status_panel
      expect(course_page.is_findable).to have_content("No – withdrawn")
      expect(course_page.status_tag).to have_content("Withdrawn")
      expect(course_page.open_for_applications).to have_content("Closed")
      expect(course_page.has_vacancies).to have_content("No")
      expect(course_page).to have_preview_link
      expect(course_page).not_to have_last_published_at
      expect(course_page).not_to have_publish
    end

    scenario "it shows a warning about the course status" do
      expect(course_page).to have_content("This course has been withdrawn")
    end
  end

  context "when the course is new" do
    let(:course) do
      build :course,
            findable?: false,
            content_status: "draft",
            ucas_status: "new",
            provider: provider
      # recruitment_cycle: current_recruitment_cycle
    end

    scenario "it displays a status panel" do
      expect(course_page).to have_status_panel
      expect(course_page.is_findable).to have_content("No")
      expect(course_page.status_tag).to have_content("Draft")
      expect(course_page).to have_preview_link
    end

    describe "publishing" do
      before do
        stub_api_v2_request(
          "/recruitment_cycles/#{current_recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses/#{course.course_code}" \
          "?include=subjects,sites,provider.sites,accrediting_provider",
          course_response,
        )
      end

      context "without errors" do
        before do
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}" \
            "/providers/#{provider.provider_code}" \
            "/courses/#{course.course_code}/publish",
            "",
            :post,
          )
        end

        scenario "it shows the show page with success flash" do
          course_page.publish.click

          expect(course_page).to be_displayed
          expect(course_page.success_summary).to have_content("Your course has been published.")
        end
      end

      context "with errors" do
        before do
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}" \
            "/providers/#{provider.provider_code}" \
            "/courses/#{course.course_code}" \
            "/publish",
            build(:error, :for_course_publish),
            :post,
            422,
          )
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}" \
            "/providers/#{provider.provider_code}" \
            "?include=courses.accrediting_provider",
            provider.to_jsonapi(include: :courses),
          )
          stub_api_v2_request(
            "/recruitment_cycles/#{current_recruitment_cycle.year}" \
            "/providers/#{provider.provider_code}" \
            "/courses/#{course.course_code}" \
            "/publishable",
            build(:error, :for_course_publish),
            :post,
            422,
          )
        end

        scenario "it shows the show page with validation errors" do
          course_page.publish.click

          expect(page.title).to have_content("Error:")
          expect(course_page).to be_displayed
          expect(course_page.error_summary).to have_content("About course can't be blank")
        end

        scenario "it deep links and persists errors" do
          course_page.publish.click

          click_link "About course can't be blank", match: :first

          expect(about_course_page.error_flash).to have_content("About course can't be blank")
        end
      end
    end
  end
end
