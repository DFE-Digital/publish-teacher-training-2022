require "rails_helper"

feature "Edit course vacancies", type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:course_vacancies_page) { PageObjects::Page::Organisations::CourseVacancies.new }
  let(:courses_page) { PageObjects::Page::Organisations::CoursesPage.new }
  let(:course_code) { "X104" }
  let(:provider) { build(:provider) }
  let(:send_vacancies_updated_notification_stub) do
    stub_request(
      :post,
      "#{Settings.teacher_training_api.base_url}/api/v2" \
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}" \
      "/send_vacancies_updated_notification",
    ).with(
      body: /"vacancy_statuses":/,
    )
  end

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
      build(:provider).to_jsonapi(include: %i[courses accrediting_provider]),
    )
    stub_request(:patch, %r{\Ahttp://localhost:3001/api/v2/site_statuses/\d+})
    stub_course_request(course)
    course_vacancies_page.load_with_course(course)
    send_vacancies_updated_notification_stub
  end

  context "A full time course with one running site" do
    let(:course) do
      build(
        :course,
        :with_full_time_vacancy,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Uni 1", :full_time, "running"),
          jsonapi_site_status("Not running Uni", :full_time, "suspended"),
        ],
      )
    end

    scenario "presents a checkbox to turn off all vacancies" do
      expect(course_vacancies_page).to have_content("I confirm there are no vacancies")
      expect(course_vacancies_page).to have_content("Close this course")
      expect(course_vacancies_page).to have_confirm_no_vacancies_checkbox
      expect(course_vacancies_page.confirm_no_vacancies_checkbox).not_to be_checked
    end

    scenario "shows an error if the form is submitted without confirming" do
      click_on "Close applications"
      expect(course_vacancies_page).to be_displayed

      expect(course_vacancies_page.error_flash)
        .to have_content("We couldn’t edit the vacancies for this course")

      expect(course_vacancies_page.error_flash)
        .to have_content("Please confirm there are no vacancies to close applications")
    end

    context "vacancies filled" do
      scenario "turns off all vacancies" do
        course_vacancies_page.confirm_no_vacancies_checkbox.check
        publish_changes("Close applications")
        expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
      end
    end
  end

  context "A full time course with one running site but no vacancies" do
    let(:site_statuses) do
      [
        jsonapi_site_status("Uni 1", :no_vacancies, "running"),
      ]
    end

    let(:course) do
      build(
        :course,
        :full_time,
        course_code: course_code,
        provider: provider,
        site_statuses: site_statuses,
      )
    end

    scenario "presents a checkbox to turn on all vacancies" do
      expect(course_vacancies_page).to have_content("I confirm there are vacancies")
      expect(course_vacancies_page).to have_content("Reopen this course")
      expect(course_vacancies_page).to have_confirm_has_vacancies_checkbox
      expect(course_vacancies_page.confirm_has_vacancies_checkbox).not_to be_checked
    end

    scenario "shows an error if the form is submitted without confirming" do
      click_on "Reopen applications"
      expect(course_vacancies_page).to be_displayed

      expect(course_vacancies_page.error_flash)
        .to have_content("We couldn’t edit the vacancies for this course")

      expect(course_vacancies_page.error_flash)
        .to have_content("Please confirm there are vacancies to reopen applications")
    end

    scenario "turns on all vacancies" do
      course_vacancies_page.confirm_has_vacancies_checkbox.check
      publish_changes("Reopen applications")
      expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
    end
  end

  context "A full time course with multiple running sites" do
    let(:course) do
      build(
        :course,
        :with_full_time_vacancy,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Running Uni 1", :full_time, "running"),
          jsonapi_site_status("Running Uni 2", :full_time, "running"),
          jsonapi_site_status("Not running Uni", :full_time, "suspended"),
        ],
      )
    end

    scenario "shows the edit vacancies page" do
      expect(course_vacancies_page).to have_link("Back", href: provider_recruitment_cycle_courses_path(provider.provider_code, course.recruitment_cycle_year))
      expect(course_vacancies_page).to have_link("Cancel changes", href: provider_recruitment_cycle_courses_path(provider.provider_code, course.recruitment_cycle_year))
      expect(course_vacancies_page.title).to have_content("Edit vacancies")
      expect(course_vacancies_page.caption).to have_content(
        "#{course.name} (#{course.course_code})",
      )
    end

    scenario "only render site statuses that are running" do
      expect(course_vacancies_page).to have_vacancies_radio_choice
      expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked

      [
        ["Running Uni 1", true],
        ["Running Uni 2", true],
      ].each do |name, checked|
        expect(course_vacancies_page.vacancies_running_sites_checkboxes).to have_field(name, checked: checked)
      end

      expect(course_vacancies_page.vacancies_running_sites_checkboxes).not_to have_field("Not running Uni")
    end
  end

  context "A full time course with multiple running sites but no vacancies" do
    let(:course) do
      build(
        :course,
        :full_time,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Running Uni 1", :no_vacancies, "running"),
          jsonapi_site_status("Running Uni 2", :no_vacancies, "running"),
        ],
      )
    end

    scenario "shows course as having no vacancies" do
      expect(course_vacancies_page).to have_vacancies_radio_choice
      expect(course_vacancies_page.vacancies_radio_no_vacancies).to be_checked
      expect(course_vacancies_page.vacancies_radio_has_some_vacancies).not_to be_checked

      [
        ["Running Uni 1", false],
        ["Running Uni 2", false],
      ].each do |name, checked|
        expect(course_vacancies_page.vacancies_running_sites_checkboxes).to have_field(name, checked: checked)
      end

      publish_changes
      expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
    end
  end

  context "A full time or part time course with one site" do
    let(:course) do
      build(
        :course,
        :with_full_time_or_part_time_vacancy,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Uni full and part time 1", :full_time_and_part_time, "running"),
        ],
      )
    end

    scenario "presents a radio button choice and shows both study modes for the site" do
      expect(course_vacancies_page).to have_vacancies_radio_choice
      expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked

      [
        ["Uni full and part time 1 (Full time)", true],
        ["Uni full and part time 1 (Part time)", true],
      ].each do |name, checked|
        expect(course_vacancies_page.vacancies_running_sites_checkboxes).to have_field(name, checked: checked)
      end
    end
  end

  context "A full time or part time course with multiple running sites" do
    let(:course) do
      build(
        :course,
        :with_full_time_or_part_time_vacancy,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Uni 1", :full_time, "running"),
          jsonapi_site_status("Uni 2", :part_time, "running"),
          jsonapi_site_status("Uni 3", :full_time_and_part_time, "running"),
          jsonapi_site_status("Not running Uni", :full_time, "suspended"),
        ],
      )
    end

    scenario "shows both study modes for each site" do
      expect(course_vacancies_page).to have_vacancies_radio_choice
      expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked

      [
        ["Uni 1 (Full time)", true],
        ["Uni 1 (Part time)", false],
        ["Uni 2 (Full time)", false],
        ["Uni 2 (Part time)", true],
        ["Uni 3 (Full time)", true],
        ["Uni 3 (Part time)", true],
      ].each do |name, checked|
        expect(course_vacancies_page.vacancies_running_sites_checkboxes).to have_field(name, checked: checked)
      end
    end
  end

  context "Removing vacancies for a course" do
    let(:course) do
      build(
        :course,
        :with_full_time_or_part_time_vacancy,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Uni 1", :full_time, "running"),
          jsonapi_site_status("Uni 2", :full_time, "running"),
        ],
      )
    end

    context "removing vacancies from a course" do
      scenario "removing a full time vacancy with no vacancies remaining" do
        expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked
        uncheck("Uni 1 (Full time)")
        uncheck("Uni 2 (Full time)")
        publish_changes
        expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
      end

      scenario "removing all vacancies" do
        expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked

        choose "There are no vacancies"
        expect(course_vacancies_page.vacancies_radio_no_vacancies).to be_checked

        publish_changes
        expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
      end
    end

    scenario "removing a full time vacancy with one remaining" do
      expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked
      uncheck("Uni 1 (Full time)")
      publish_changes
      expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
    end
  end

  context "Adding vacancies to a course" do
    let(:course) do
      build(
        :course,
        :with_full_time_vacancy,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Uni 1", :no_vacancies, "running"),
          jsonapi_site_status("Uni 2", :no_vacancies, "running"),
        ],
      )
    end

    scenario "all locations have vacancies" do
      expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked

      choose "There are some vacancies"
      check("Uni 1")
      check("Uni 2")

      publish_changes
      expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
    end

    scenario "some locations have vacancies" do
      expect(course_vacancies_page.vacancies_radio_has_some_vacancies).to be_checked

      choose "There are some vacancies"
      check("Uni 1")

      publish_changes
      expect(send_vacancies_updated_notification_stub).to have_been_requested.times(1)
    end
  end

  context "Adding vacancies for a course" do
    let(:course) do
      build(
        :course,
        :with_full_time_or_part_time_vacancy,
        course_code: course_code,
        provider: provider,
        site_statuses: [
          jsonapi_site_status("Uni 1", :full_time, "running"),
        ],
      )
    end

    scenario "adding a part time vacancy" do
      check("Uni 1 (Part time)")
      publish_changes
    end
  end

  def publish_changes(button_text = "Publish changes")
    click_on button_text
    expect(courses_page).to be_displayed
    expect(courses_page.flash).to have_content("Course vacancies published")
  end

  def jsonapi_site_status(name, study_mode, status)
    build(:site_status, study_mode, site: build(:site, location_name: name), status: status)
  end

  def stub_course_request(course)
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}/courses" \
      "/#{course.course_code}" \
      "?include=site_statuses.site",
      course.to_jsonapi(include: [:sites, site_statuses: :site]),
    )
  end
end
