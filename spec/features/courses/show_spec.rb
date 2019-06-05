require 'rails_helper'

feature 'Show course', type: :feature do
  let(:provider) { jsonapi(:provider, accredited_body?: false) }
  let(:course) {
    jsonapi :course,
            qualifications: %w[qts pgce],
            study_mode: 'full_time',
            start_date: Time.new(2019),
            sites: [site1, site2],
            provider: provider,
            accrediting_provider: provider,
            open_for_applications?: true
  }
  let(:site1) { jsonapi(:site, location_name: 'London') }
  let(:site2) { jsonapi(:site, location_name: 'Manchester') }
  let(:site_status1) do
    jsonapi(:site_status, :full_time, site: site1, status: 'running')
  end
  let(:site_status2) do
    jsonapi(:site_status, :part_time, site: site2, status: 'suspended')
  end
  let(:course_response) { course.render }
  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/A0/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course_response
    )
  end

  let(:course_page) { PageObjects::Page::Organisations::Course.new }

  scenario 'viewing the show courses page' do
    visit "/organisations/A0/courses/#{course.course_code}"

    expect(course_page)
      .to be_displayed(provider_code: 'A0', course_code: course.course_code)

    expect(course_page.caption).to have_content(
      course.description
    )
    expect(course_page.title).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_page.subjects).to have_content(
      course.subjects.sort.join('').to_s
    )
    expect(course_page.qualifications).to have_content(
      'PGCE with QTS'
    )
    expect(course_page.study_mode).to have_content(
      'Full time'
    )
    expect(course_page.start_date).to have_content(
      'January 2019'
    )
    expect(course_page.name).to have_content(
      course.name
    )
    expect(course_page.description).to have_content(
      course.description
    )
    expect(course_page.course_code).to have_content(
      course.course_code
    )
    expect(course_page.locations).to have_content(
      site1.location_name
    )
    expect(course_page.locations).to have_content(
      site2.location_name
    )
    expect { course_page.apprenticeship }.to raise_error(Capybara::ElementNotFound)
    expect(course_page.funding).to have_content(
      'Fee paying (no salary)'
    )
    expect(course_page.accredited_body).to have_content(
      provider.provider_name
    )
    expect(course_page.application_status).to have_content(
      'Open'
    )
    expect(course_page.is_send).to have_content(
      'No'
    )
    expect(course_page.level).to have_content(
      'Secondary'
    )
    expect(course_page).to have_entry_requirements
  end

  context 'when the course is new and not running' do
    let(:course) {
      jsonapi :course,
              sites: [site1, site2],
              provider: provider,
              accrediting_provider: provider,
              ucas_status: 'new'
    }

    scenario 'viewing the show courses page' do
      visit "/organisations/A0/courses/#{course.course_code}"

      expect(course_page.locations).to have_content(
        site1.location_name
      )
      expect(course_page.locations).to have_content(
        site2.location_name
      )
    end
  end

  scenario 'viewing the show page for a course that does not exist' do
    stub_api_v2_request(
      "/providers/ZZ/courses/ZZZ?include=sites,provider.sites,accrediting_provider",
      '',
      :get,
      404
    )

    course
    visit "/organisations/ZZ/courses/ZZZ"

    expect(course_page)
    .to be_displayed(provider_code: 'ZZ', course_code: 'ZZZ')
    expect(course_page.title.text).to eq 'Page not found'
  end
end
