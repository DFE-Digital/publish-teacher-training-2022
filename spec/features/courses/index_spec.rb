require 'rails_helper'

feature 'Index courses', type: :feature do
  let(:course_1) { jsonapi :course, name: 'English', include_nulls: [:accrediting_provider] }
  let(:course_2) {
    jsonapi :course,
            name: 'Mathematics',
            findable?: true,
            open_for_applications?: true,
            has_vacancies?: true,
            include_nulls: [:accrediting_provider]
  }
  let(:course_3) { jsonapi :course, findable?: false, name: 'Physics', content_status: "empty", include_nulls: [:accrediting_provider] }
  let(:course_4) { jsonapi :course, findable?: false, name: 'Science', content_status: "published", include_nulls: [:accrediting_provider] }
  let(:courses)  { [course_1, course_2, course_3, course_4] }
  let(:provider) do
    jsonapi(:provider, courses: courses, accredited_body?: true, provider_code: 'A123')
  end
  let(:provider_response) { provider.render }
  let(:root_page) { PageObjects::Page::RootPage.new }
  let(:organisation_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:courses_page) { PageObjects::Page::Organisations::Courses.new }

  describe "without accrediting providers" do
    before do
      user = build(:user)
      stub_omniauth(user: user)
      stub_api_v2_request('/providers', jsonapi(:providers_response, data: [provider_response[:data]]))
      stub_api_v2_request("/providers/A123", provider_response)
      stub_api_v2_request(
        "/providers/A123?include=courses.accrediting_provider",
        provider_response
      )
      root_page.load
      expect(organisation_page).to be_displayed(provider_code: 'A123')
      organisation_page.courses.click
    end

    scenario 'it shows a list of courses' do
      expect(courses_page.title).to have_content('Courses')
      courses_table = courses_page.courses_tables.first
      expect(courses_table.rows.size).to eq(4)

      first_row = courses_table.rows.first
      expect(first_row.name).to           have_content course_1.attributes[:name]
      expect(first_row.ucas_status).to    have_content 'Running'
      expect(first_row.content_status).to have_content 'Published'
      expect(first_row.is_it_on_find).to  have_content 'Yes - view online'
      expect(first_row.applications).to   have_content 'Closed'
      expect(first_row.vacancies).to      have_content 'No (Edit)'
      expect(first_row.find_link['href']).to eq(
        "https://localhost:5000/course/A123/#{course_1.attributes[:course_code]}"
      )
      expect(first_row.link['href']).to eq(
        "/organisations/A123/courses/#{course_1.attributes[:course_code]}"
      )

      second_row = courses_table.rows.second
      expect(second_row.name).to          have_content course_2.attributes[:name]
      expect(second_row.is_it_on_find).to have_content('Yes - view online')
      expect(second_row.applications).to  have_content 'Open'
      expect(second_row.vacancies).to     have_content 'Yes (Edit)'
      expect(second_row.find_link['href']).to eql(
        "https://localhost:5000/course/A123/#{course_2.attributes[:course_code]}"
      )

      third_row = courses_table.rows.third
      expect(third_row.name).to           have_content course_3.attributes[:name]
      expect(third_row.content_status).to have_content 'Empty'
      expect(third_row.is_it_on_find).to  have_content 'No'
      expect(third_row.applications).to   have_content ''
      expect(third_row.vacancies).to      have_content ''

      fourth_row = courses_table.rows.fourth
      expect(fourth_row.name).to           have_content course_4.attributes[:name]
      expect(fourth_row.content_status).to have_content ''
      expect(fourth_row.is_it_on_find).to  have_content 'No'
      expect(fourth_row.applications).to   have_content ''
      expect(fourth_row.vacancies).to      have_content ''
    end

    scenario "it shows 'add a new course' link" do
      expect(courses_page).to have_link_to_add_a_course_for_accredited_bodies
    end
  end

  describe "with accrediting providers" do
    let(:provider) do
      jsonapi(:provider, courses: courses, accredited_body?: false, provider_code: 'A123')
    end
    let(:provider_response) { provider.render }
    let(:provider_1) { jsonapi :provider, id: "1", provider_name: "Zacme Scitt" }
    let(:provider_2) { jsonapi :provider, id: "2", provider_name: "Aacme Scitt" }
    let(:provider_3) { jsonapi :provider, id: "3", provider_name: "e-Qualitas" }

    let(:course_2) { jsonapi :course, accrediting_provider: provider_1 }
    let(:course_3) { jsonapi :course, accrediting_provider: provider_2 }
    let(:course_4) { jsonapi :course, accrediting_provider: provider_3 }

    before do
      user = build(:user)
      stub_omniauth(user: user)
      stub_api_v2_request('/providers', jsonapi(:providers_response, data: [provider_response[:data]]))
      stub_api_v2_request("/providers/A123", provider_response)
      stub_api_v2_request(
        "/providers/A123?include=courses.accrediting_provider",
        provider_response
      )
      root_page.load
      expect(organisation_page).to be_displayed(provider_code: 'A123')
      organisation_page.courses.click
    end

    scenario "it shows a list of courses" do
      expect(courses_page.title).to have_content('Courses')
      expect(courses_page.courses_tables.size).to eq(4)

      expect(courses_page.courses_tables.first).to_not have_subheading
      expect(courses_page.courses_tables.second.subheading).to have_content('Accredited body Aacme Scitt')
      expect(courses_page.courses_tables.third.subheading).to have_content('Accredited body e-Qualitas')
      expect(courses_page.courses_tables.fourth.subheading).to have_content('Accredited body Zacme Scitt')
    end

    scenario "it shows 'add a new course' link" do
      expect(courses_page).to have_link_to_add_a_course_for_unaccredited_bodies
    end
  end
end
