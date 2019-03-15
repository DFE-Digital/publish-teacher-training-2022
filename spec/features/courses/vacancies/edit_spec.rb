require 'rails_helper'

feature 'Edit course vacancies', type: :feature do
  let(:course) do
    jsonapi(:course,
            has_vacancies?: true,
            course_code: 'C1D3',
            name: 'English',
            study_mode: 'full_time_or_part_time',
            site_statuses: [
              jsonapi(:site_status,
                      id: 1,
                      vac_status: 'both_full_time_and_part_time_vacancies',
                      site: build(:site,
                                  id: 3,
                                  code: '-',
                                  location_name: 'Big school'))
            ]).render
  end

  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request '/providers/AO/courses/C1D3', course
  end

  scenario 'viewing the edit vacancies page' do
    visit '/organisations/AO/courses/C1D3/vacancies'

    expect(page).to have_link(
      'Back',
      href: "#{Settings.manage_ui.base_url}/organisation/AO/course/self/C1D3"
    )
    expect(page).to have_link(
      'Cancel changes',
      href: "#{Settings.manage_ui.base_url}/organisation/AO/course/self/C1D3"
    )
    expect(find('h1')).to have_content('Edit vacancies')
    expect(find('.govuk-caption-xl')).to have_content('English (C1D3)')
  end

  context 'where the course is both full time or part time' do
    let(:course_without_full_time_vacancy) do
      jsonapi(:course,
              has_vacancies?: true,
              course_code: 'C1D3',
              name: 'English',
              study_mode: 'full_time_or_part_time',
              site_statuses: [
                jsonapi(:site_status,
                        id: 1,
                        vac_status: 'part_time_vacancies',
                        site: build(:site,
                                    id: 3,
                                    code: '-',
                                    location_name: 'Big school'))
              ]).render
    end

    before do
      stub_request :patch, 'http://localhost:3001/api/v2/site_statuses/1'
    end

    scenario 'adding a vacancy' do
      visit '/organisations/AO/courses/C1D3/vacancies'

      check('Big school (Full time)', allow_label_click: true)
      stub_api_v2_request '/providers/AO/courses/C1D3', course_without_full_time_vacancy
      click_on 'Publish changes'

      expect(page.find('.govuk-success-summary')).to have_content 'Course vacancies published'
      expect(page).to have_field('Big school (Full time)', checked: false)
    end
  end
end
