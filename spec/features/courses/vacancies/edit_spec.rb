require 'rails_helper'

feature 'Edit course vacancies', type: :feature do
  let(:base_course) do
    {
      data: {
        id: '1',
        type: 'courses',
        attributes: {
          has_vacancies?: true,
          course_code: 'C1D3',
          name: 'English',
          study_mode: 'full_time_or_part_time'
        },
        relationships: {
          provider: {
            meta: {
              included: false
            }
          },
          site_statuses: {
            data: [
              {
                type: 'site_statuses',
                id: '1'
              },
              {
                type: 'site_statuses',
                id: '2'
              },
              {
                type: 'site_statuses',
                id: '3'
              },
              {
                type: 'site_statuses',
                id: '4'
              }
            ]
          }
        }
      },
      included: [
        {
          id: '1',
          type: 'site_statuses',
          attributes: {
            vac_status: 'both_full_time_and_part_time_vacancies'
          },
          relationships: {
            site: {
              data: {
                type: 'sites',
                id: '3'
              }
            }
          }
        },
        {
          id: '2',
          type: 'site_statuses',
          attributes: {
            vac_status: 'full_time_vacancies'
          },
          relationships: {
            site: {
              data: {
                type: 'sites',
                id: '3'
              }
            }
          }
        },
        {
          id: '3',
          type: 'site_statuses',
          attributes: {
            vac_status: 'part_time_vacancies'
          },
          relationships: {
            site: {
              data: {
                type: 'sites',
                id: '3'
              }
            }
          }
        },
        {
          id: '4',
          type: 'site_statuses',
          attributes: {
            vac_status: 'no_vacancies'
          },
          relationships: {
            site: {
              data: {
                type: 'sites',
                id: '3'
              }
            }
          }
        },
        {
          id: '3',
          type: 'sites',
          attributes: {
            code: '2',
            location_name: 'Main Site'
          }
        }
      ]
    }
  end
  let(:course) { base_course }

  before do
    stub_omniauth
    stub_session_create
    stub_api_v2_request '/providers/AO/courses/C1D3', course
  end

  scenario 'viewing the edit vacancies page' do
    visit '/organisations/AO/courses/C1D3/vacancies'

    expect(page).to have_link(
      'Back',
      href: "#{Settings.manage_ui.base_url}/organisation/AO/courses/self/C1D3"
    )
    expect(page).to have_link(
      'Cancel changes',
      href: "#{Settings.manage_ui.base_url}/organisation/AO/courses/self/C1D3"
    )
    expect(find('h1')).to have_content('Edit vacancies')
    expect(find('.govuk-caption-xl')).to have_content('English (C1D3)')
  end

  describe 'rendering forms' do
    context 'with a course that has full and part time sites' do
      scenario 'it shows full time checkbox for each site' do
        visit '/organisations/AO/courses/C1D3/vacancies'

        expect(page.find('input#course_site_status_attributes_0_full_time'))
          .to be_checked
        expect(page.find('input#course_site_status_attributes_0_part_time'))
          .to be_checked

        expect(page.find('input#course_site_status_attributes_1_full_time'))
          .to be_checked
        expect(page.find('input#course_site_status_attributes_1_part_time'))
          .not_to be_checked

        expect(page.find('input#course_site_status_attributes_2_full_time'))
          .not_to be_checked
        expect(page.find('input#course_site_status_attributes_2_part_time'))
          .to be_checked

        expect(page.find('input#course_site_status_attributes_3_full_time'))
          .not_to be_checked
        expect(page.find('input#course_site_status_attributes_3_part_time'))
          .not_to be_checked
      end
    end

    context 'with a course with full time sites' do
      let(:course) do
        base_course[:data][:attributes][:study_mode] = 'full_time'

        base_course[:included].delete_at 0
        base_course[:included].delete_at 1

        base_course[:data][:relationships][:site_statuses][:data].delete_at 0
        base_course[:data][:relationships][:site_statuses][:data].delete_at 1

        base_course
      end

      scenario 'it shows full time checkbox for each site' do
        visit '/organisations/AO/courses/C1D3/vacancies'

        expect(page.find('input#course_site_status_attributes_0_full_time'))
          .to be_checked
        expect(page.find('input#course_site_status_attributes_1_full_time'))
          .not_to be_checked

        expect(page.has_css?('input#course_site_status_attributes_0_part_time'))
          .to eq false
        expect(page.has_css?('input#course_site_status_attributes_1_part_time'))
          .to eq false
      end
    end

    context 'with a course with part time sites' do
      let(:course) do
        base_course[:data][:attributes][:study_mode] = 'part_time'

        base_course[:included].delete_at 0
        base_course[:included].delete_at 0

        base_course[:data][:relationships][:site_statuses][:data].delete_at 0
        base_course[:data][:relationships][:site_statuses][:data].delete_at 0

        base_course
      end

      scenario 'it shows part time checkbox for each site' do
        visit '/organisations/AO/courses/C1D3/vacancies'

        expect(page.find('input#course_site_status_attributes_0_part_time'))
          .to be_checked
        expect(page.find('input#course_site_status_attributes_1_part_time'))
          .not_to be_checked

        expect(page.has_css?('input#course_site_status_attributes_0_full_time'))
          .to eq false
        expect(page.has_css?('input#course_site_status_attributes_1_full_time'))
          .to eq false
      end
    end
  end

  describe 'submitting forms' do
    let(:course_without_vacancy) do
      course[:included][0][:attributes][:vac_status] = 'no_vacancies'
      course
    end

    let(:course_with_vacancy) do
      course[:included][0][:attributes][:vac_status] = 'full_time_vacancies'
      course
    end

    before do
      stub_request :patch, 'http://localhost:3001/api/v2/site_statuses/1'
      stub_request :patch, 'http://localhost:3001/api/v2/site_statuses/2'
      stub_request :patch, 'http://localhost:3001/api/v2/site_statuses/3'
      stub_request :patch, 'http://localhost:3001/api/v2/site_statuses/4'
    end

    scenario 'removing a vacancy' do
      visit '/organisations/AO/courses/C1D3/vacancies'

      page.find('input#course_site_status_attributes_0_full_time').uncheck
      stub_api_v2_request '/providers/AO/courses/C1D3', course_without_vacancy
      click_on 'Publish changes'

      expect(current_path).to eq vacancies_provider_course_path('AO', 'C1D3')
      expect(page.find('.govuk-success-summary'))
        .to have_content 'Course vacancies published'
      expect(page.find('input#course_site_status_attributes_0_full_time'))
        .not_to be_checked
    end

    scenario 'removing all vacancies' do
      visit '/organisations/AO/courses/C1D3/vacancies'

      page.find('input#course_has_vacancies_false').click
      stub_api_v2_request '/providers/AO/courses/C1D3', course_with_vacancy
      click_on 'Publish changes'

      expect(current_path).to eq vacancies_provider_course_path('AO', 'C1D3')
      expect(page.find('.govuk-success-summary'))
        .to have_content 'Course vacancies published'
      expect(page.find('input#course_has_vacancies_false'))
        .to be_truthy
    end

    scenario 'adding a vacancy' do
      visit '/organisations/AO/courses/C1D3/vacancies'

      page.find('input#course_site_status_attributes_0_full_time').check
      stub_api_v2_request '/providers/AO/courses/C1D3', course_with_vacancy
      click_on 'Publish changes'

      expect(current_path).to eq vacancies_provider_course_path('AO', 'C1D3')
      expect(page.find('input#course_site_status_attributes_0_full_time'))
        .to be_checked
    end
  end
end
