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
    jsonapi(:provider, :opted_in, courses: courses, accredited_body?: true, provider_code: 'A123')
  end
  let(:provider_response) { provider.render }
  let(:courses_page) { PageObjects::Page::Organisations::Courses.new }

  describe "without accrediting providers" do
    before do
      user = jsonapi :user, :opted_in
      stub_omniauth(disable_completely: false, user: user)
      stub_session_create(user: User.new(JSON.parse(user.to_json)))
      stub_api_v2_request('/providers', jsonapi(:providers_response, data: [provider_response[:data]]))
      stub_api_v2_request("/providers/A123", provider_response)
      stub_api_v2_request(
        "/providers/A123?include=courses.accrediting_provider",
        provider_response
      )
      visit "/"
      click_on "Courses"
    end

    scenario 'it shows a list of courses' do
      expect(find('h1')).to have_content('Courses')
      expect(page).to have_selector('tbody tr', count: provider.relationships[:courses].size)

      first_row = courses_page.rows.first
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
        "https://localhost:44364/organisation/A123/course/self/#{course_1.attributes[:course_code]}"
      )

      second_row = courses_page.rows.second
      expect(second_row.name).to          have_content course_2.attributes[:name]
      expect(second_row.is_it_on_find).to have_content('Yes - view online')
      expect(second_row.applications).to  have_content 'Open'
      expect(second_row.vacancies).to     have_content 'Yes (Edit)'
      expect(second_row.find_link['href']).to eql(
        "https://localhost:5000/course/A123/#{course_2.attributes[:course_code]}"
      )

      third_row = courses_page.rows.third
      expect(third_row.name).to           have_content course_3.attributes[:name]
      expect(third_row.content_status).to have_content 'Empty'
      expect(third_row.is_it_on_find).to  have_content 'No'
      expect(third_row.applications).to   have_content ''
      expect(third_row.vacancies).to      have_content ''

      fourth_row = courses_page.rows.fourth
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
      jsonapi(:provider, :opted_in, courses: courses, accredited_body?: false, provider_code: 'A123')
    end
    let(:provider_response) { provider.render }
    let(:provider_1) { jsonapi :provider, id: "1", provider_name: "Zacme Scitt" }
    let(:provider_2) { jsonapi :provider, id: "2", provider_name: "Aacme Scitt" }

    let(:course_2) { jsonapi :course, accrediting_provider: provider_1 }
    let(:course_3) { jsonapi :course, accrediting_provider: provider_2 }

    before do
      user = jsonapi :user, :opted_in
      stub_omniauth(disable_completely: false, user: user)
      stub_session_create(user: User.new(JSON.parse(user.to_json)))
      stub_api_v2_request('/providers', jsonapi(:providers_response, data: [provider_response[:data]]))
      stub_api_v2_request("/providers/A123", provider_response)
      stub_api_v2_request(
        "/providers/A123?include=courses.accrediting_provider",
        provider_response
      )
      visit "/"
      click_on "Courses"
    end

    scenario "it shows a list of courses" do
      expect(find('h1')).to have_content('Courses')
      expect(page).to have_selector('table', count: 3)

      expect(page.all('h2')[0]).to have_content('Accredited body Aacme Scitt')
      expect(page.all('h2')[1]).to have_content('Accredited body Zacme Scitt')
    end

    scenario "it shows 'add a new course' link" do
      expect(courses_page).to have_link_to_add_a_course_for_unaccredited_bodies
    end
  end

  describe "with a not opted in provider" do
    let(:provider) do
      jsonapi(:provider, opted_in: false, courses: courses, provider_code: 'A321')
    end
    let(:provider_response) { provider.render }

    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request(
        "/providers/A321?include=courses.accrediting_provider",
        provider_response
      )
      visit "/organisations/A321/courses"
    end

    scenario "it does not show the 'add a new course' link" do
      visit "/organisations/A321/courses"

      expect(page).to_not have_link('Add a new course')
    end
  end
end
