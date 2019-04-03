require 'rails_helper'

feature 'Index courses', type: :feature do
  let(:course_1) { jsonapi :course, include_nulls: [:accrediting_provider] }
  let(:course_2) { jsonapi :course, include_nulls: [:accrediting_provider] }
  let(:course_3) { jsonapi :course, include_nulls: [:accrediting_provider] }
  let(:courses)  { [course_1, course_2, course_3] }
  let(:provider) do
    jsonapi(:provider, courses: courses)
  end
  let(:provider_response) { provider.render }

  describe "without accrediting providers" do
    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request(
        "/providers/#{provider.attributes[:provider_code]}?include=courses.accrediting_provider",
        provider_response
      )
    end

    scenario 'it shows a list of courses' do
      visit "/organisations/#{provider.attributes[:provider_code]}/courses"

      expect(find('h1')).to have_content('Courses')
      expect(page).to have_selector('tbody tr', count: provider.relationships[:courses].size)

      expect(first('[data-qa="courses-table__course"]')).to have_content(course_1.attributes[:name])
      expect(first('[data-qa="courses-table__course"]')).to have_content(course_2.attributes[:name])
      expect(first('[data-qa="courses-table__course"]')).to have_content(course_3.attributes[:name])
      expect(page).to have_selector("a[href=\"https://localhost:44364/organisation/#{provider.attributes[:provider_code]}/course/self/#{course_1.attributes[:course_code]}\"]")

      expect(first('[data-qa="courses-table__ucas-status"]')).to have_content('Running')

      expect(first('[data-qa="courses-table__content-status"]')).to have_content('Published')

      expect(first('[data-qa="courses-table__findable"]')).to have_content('Yes - view online')
      expect(page).to have_selector("a[href=\"https://localhost:5000/course/#{provider.attributes[:provider_code]}/#{course_1.attributes[:course_code]}\"]")

      expect(first('[data-qa="courses-table__applications"]')).to have_content('Closed')
      expect(first('[data-qa="courses-table__vacancies"]')).to have_content('No (Edit)')
    end
  end

  describe "with accrediting providers" do
    let(:provider_1) { jsonapi :provider, id: "1", provider_name: "Zacme Scitt" }
    let(:provider_2) { jsonapi :provider, id: "2", provider_name: "Aacme Scitt" }

    let(:course_2) { jsonapi :course, accrediting_provider: provider_1 }
    let(:course_3) { jsonapi :course, accrediting_provider: provider_2 }

    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request(
        "/providers/#{provider.attributes[:provider_code]}?include=courses.accrediting_provider",
        provider_response
      )
    end

    scenario "it shows a list of courses" do
      visit "/organisations/#{provider.attributes[:provider_code]}/courses"

      expect(find('h1')).to have_content('Courses')
      expect(page).to have_selector('table', count: 3)

      expect(page.all('h2')[0]).to have_content('Accredited body Aacme Scitt')
      expect(page.all('h2')[1]).to have_content('Accredited body Zacme Scitt')
    end
  end
end
