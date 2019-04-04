require 'rails_helper'

feature 'Index courses', type: :feature do
  let(:course_1) { jsonapi :course }
  let(:course_2) { jsonapi :course }
  let(:courses)  { [course_1, course_2] }
  let(:provider) do
    jsonapi(:provider, courses: courses)
  end
  let(:provider_response) { provider.render }
  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request(
      "/providers/#{provider.attributes[:provider_code]}?include=courses",
      provider_response
    )
  end

  scenario 'it shows a list of courses' do
    visit "/organisations/#{provider.attributes[:provider_code]}/courses"

    expect(find('h1')).to have_content('Courses')
    expect(page).to have_selector('tbody tr', count: provider.relationships[:courses].size)

    expect(first('[data-qa="courses-table__course"]')).to have_content(course_1.attributes[:name])
    expect(first('[data-qa="courses-table__course"]')).to have_content(course_2.attributes[:name])
    expect(page).to have_selector("a[href=\"https://localhost:44364/organisation/#{provider.attributes[:provider_code]}/course/self/X101\"]")

    expect(first('[data-qa="courses-table__ucas-status"]')).to have_content('Running')

    expect(first('[data-qa="courses-table__content-status"]')).to have_content('Published')

    expect(first('[data-qa="courses-table__findable"]')).to have_content('Yes - view online')
    expect(page).to have_selector("a[href=\"https://localhost:5000/course/#{provider.attributes[:provider_code]}/X101\"]")

    expect(first('[data-qa="courses-table__applications"]')).to have_content('Closed')
    expect(first('[data-qa="courses-table__vacancies"]')).to have_content('No (Edit)')
  end
end
