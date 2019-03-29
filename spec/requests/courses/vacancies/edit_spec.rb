# require 'rails_helper'

# describe Courses::VacanciesController, type: :controller do
#   let(:full_and_part_time_site) { build(:site, id: 3, code: '-', location_name: 'Full & part time site') }
#   let(:full_time_site)          { build(:site, id: 3, code: 'A', location_name: 'Full time site') }
#   let(:part_time_site)          { build(:site, id: 3, code: 'B', location_name: 'Part time site') }
#   let(:no_vacancies_site)       { build(:site, id: 3, code: 'C', location_name: 'No vacancies site') }

#   let(:full_and_part_time_site_status) { build(:site_status, id: 1, site: full_and_part_time_site) }
#   let(:full_time_site_status)          { build(:site_status, id: 2, site: full_time_site, vac_status: 'full_time_vacancies') }
#   let(:part_time_site_status)          { build(:site_status, id: 3, site: part_time_site, vac_status: 'part_time_vacancies') }
#   let(:no_vacancies_site_status)       { build(:site_status, id: 4, site: no_vacancies_site, vac_status: 'no_vacancies') }

#   # let(:course) do
#   #   build(:course, has_vacancies?: true,
#   #                  course_code: 'C1D3',
#   #                  name: 'English',
#   #                  study_mode: 'full_time_or_part_time',
#   #                  site_statuses: [
#   #                    full_and_part_time_site_status,
#   #                    full_time_site_status,
#   #                    part_time_site_status,
#   #                    no_vacancies_site_status,
#   #                  ])
#   # end

#   context 'with authenticated user' do
#     before do
#       stub_omniauth
#       stub_session_create
#     end

#     describe 'GET #edit' do
#       # binding.pry;
#       subject { get :edit, params: { id: course['attributes'][:course_code] } }

#       it { is_expected.to be_successful }
#       it { is_expected.to render_template :edit }
#     end
#   end
# end
