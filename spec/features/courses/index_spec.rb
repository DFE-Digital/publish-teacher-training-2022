require 'rails_helper'

feature 'Index courses', type: :feature do
  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request('/providers', build(:providers_response))
    stub_api_v2_request('/providers/AO/courses', build(:courses_response))
  end

  scenario 'it shows a list of courses' do
    visit '/organisations/AO/courses'

    expect(find('h1')).to have_content('Courses')
    expect(page).to have_selector('tbody tr', count: 3)

    expect(first('[data-qa="courses-table__course"]')).to have_content('English (X101)')
    expect(first('[data-qa="courses-table__findable"]')).to have_content('Yes - view online')
    expect(first('[data-qa="courses-table__applications"]')).to have_content('Closed')
    expect(first('[data-qa="courses-table__vacancies"]')).to have_content('No (Edit)')
  end
end
