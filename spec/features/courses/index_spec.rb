require 'rails_helper'

feature 'Index courses', type: :feature do
  let(:course_1) { jsonapi :course, name: 'English', include_nulls: [:accrediting_provider] }
  let(:course_2) { jsonapi :course, name: 'Mathematics', include_nulls: [:accrediting_provider] }
  let(:course_3) { jsonapi :course, name: 'Physics', include_nulls: [:accrediting_provider] }
  let(:courses)  { [course_1, course_2, course_3] }
  let(:provider) do
    jsonapi(:provider, courses: courses, provider_code: 'A123')
  end
  let(:provider_response) { provider.render }

  describe "without accrediting providers" do
    before do
      stub_omniauth
      stub_session_create
      stub_api_v2_request(
        "/providers/A123?include=courses.accrediting_provider",
        provider_response
      )
    end

    scenario 'it shows a list of courses' do
      visit "/organisations/A123/courses"

      expect(find('h1')).to have_content('Courses')
      expect(page).to have_selector('tbody tr', count: provider.relationships[:courses].size)

      first_row, second_row, third_row = find_all('tbody .govuk-table__row').to_a
      within first_row do
        expect(find('[data-qa="courses-table__course"]')).to have_content(course_1.attributes[:name])
        expect(first_row).to have_selector("a[href=\"https://localhost:44364/organisation/A123/course/self/#{course_1.attributes[:course_code]}\"]")

        expect(find('[data-qa="courses-table__ucas-status"]')).to have_content('Running')

        expect(find('[data-qa="courses-table__content-status"]')).to have_content('Published')

        expect(find('[data-qa="courses-table__findable"]')).to have_content('Yes - view online')
        expect(first_row).to have_selector("a[href=\"https://localhost:5000/course/A123/#{course_1.attributes[:course_code]}\"]")

        expect(find('[data-qa="courses-table__applications"]')).to have_content('Closed')
        expect(find('[data-qa="courses-table__vacancies"]')).to have_content('No (Edit)')
      end

      within second_row do
        expect(find('[data-qa="courses-table__course"]')).to have_content(course_2.attributes[:name])
      end

      within third_row do
        expect(find('[data-qa="courses-table__course"]')).to have_content(course_3.attributes[:name])
      end
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
        "/providers/A123?include=courses.accrediting_provider",
        provider_response
      )
    end

    scenario "it shows a list of courses" do
      visit "/organisations/A123/courses"

      expect(find('h1')).to have_content('Courses')
      expect(page).to have_selector('table', count: 3)

      expect(page.all('h2')[0]).to have_content('Accredited body Aacme Scitt')
      expect(page.all('h2')[1]).to have_content('Accredited body Zacme Scitt')
    end
  end
end
