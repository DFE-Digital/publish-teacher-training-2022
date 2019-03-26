require 'rails_helper'

feature 'Edit course vacancies', type: :feature do
  let(:course) do
    JSON.parse(
      <<~STRING
        {
           "data":{
              "id":"1",
              "type":"courses",
              "attributes":{
                 "findable?":true,
                 "open_for_applications?":true,
                 "has_vacancies?":true,
                 "course_code":"C1D3",
                 "name":"Umple",
                 "study_mode":"full_time",
                 "qualifications":[
                    "qts",
                    "pgce"
                 ],
                 "description":"PGCE with QTS full time",
                 "start_date":"2019-03-25T17:19:56Z"
              },
              "relationships":{
                 "provider":{
                    "meta":{
                       "included":false
                    }
                 },
                 "accrediting_provider":{
                    "meta":{
                       "included":false
                    }
                 },
                 "site_statuses":{
                    "data":[
                       {
                          "type":"site_statuses",
                          "id":"1"
                       }
                    ]
                 }
              }
           },
           "included":[
              {
                 "id":"1",
                 "type":"site_statuses",
                 "attributes":{
                    "vac_status":"full_time_vacancies",
                    "publish":"published",
                    "status":"running",
                    "applications_accepted_from":"2019-03-23"
                 },
                 "relationships":{
                    "site":{
                       "data":{
                          "type":"sites",
                          "id":"3"
                       }
                    }
                 }
              },
              {
                 "id":"3",
                 "type":"sites",
                 "attributes":{
                    "code":"2",
                    "location_name":"Main Site848139"
                 }
              }
           ],
           "jsonapi":{
              "version":"1.0"
           }
        }
      STRING
    )
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
      href: "#{Settings.manage_ui.base_url}/organisation/AO/courses/C1D3"
    )
    expect(find('h1')).to have_content('Edit vacancies')
    expect(find('.govuk-caption-xl')).to have_content('Umple (C1D3)')
  end

  context 'with a full time course' do
    let(:course_without_vacancy) do
      course['included'].first['attributes']['vac_status'] = 'no_vacancies'
      course
    end

    before do
      stub_request :patch, 'http://localhost:3001/api/v2/site_statuses/1'
    end

    scenario 'removing a vacancy' do
      visit '/organisations/AO/courses/C1D3/vacancies'

      uncheck 'Main Site848139 (Full time)', allow_label_click: true
      stub_api_v2_request '/providers/AO/courses/C1D3', course_without_vacancy
      click_on 'Publish changes'

      expect(current_path).to eq vacancies_provider_course_path('AO', 'C1D3')
      expect(page.find('input#course_site_status_attributes_0_full_time'))
        .not_to be_checked
    end
  end
end
