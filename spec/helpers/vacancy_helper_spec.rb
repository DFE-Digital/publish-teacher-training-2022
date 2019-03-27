require 'rails_helper'

RSpec.feature 'Vacancy helpers', type: :helper do
  # TODO: Refactor this, the site status doubles in particular.

  describe '#are_vacancies_available_for_course_site_status' do
    let(:vacancy_study_mode) { nil }

    subject do
      helper.are_vacancies_available_for_course_site_status?(
        course,
        site_status,
        vacancy_study_mode
      )
    end

    context 'with a full time or part time course' do
      let(:course) do
        double(
          :course,
          full_time_or_part_time?: true,
          full_time?: false,
          part_time?: false
        )
      end

      context 'when the vacancy study mode is full time' do
        let(:vacancy_study_mode) { :full_time }

        context 'with a full and part time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: true,
              full_time_vacancies?:               false,
              part_time_vacancies?:               false
            )
          end

          it { should eq true }
        end

        context 'with a full time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               true,
              part_time_vacancies?:               false
            )
          end

          it { should eq true }
        end

        context 'with a part time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               false,
              part_time_vacancies?:               true
            )
          end

          it { should eq false }
        end

        context 'with no vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               false,
              part_time_vacancies?:               false
            )
          end

          it { should eq false }
        end
      end

      context 'when the vacancy study mode is part time' do
        let(:vacancy_study_mode) { :part_time }

        context 'with a full and part time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: true,
              full_time_vacancies?:               false,
              part_time_vacancies?:               false
            )
          end

          it { should eq true }
        end

        context 'with a full time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               true,
              part_time_vacancies?:               false
            )
          end

          it { should eq false }
        end

        context 'with a part time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               false,
              part_time_vacancies?:               true
            )
          end

          it { should eq true }
        end

        context 'with no vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               false,
              part_time_vacancies?:               false
            )
          end

          it { should eq false }
        end
      end

      context 'without a vacancy study mode set' do
        context 'with a full and part time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: true,
              full_time_vacancies?:               false,
              part_time_vacancies?:               false
            )
          end

          it { should eq true }
        end

        context 'with a full time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               true,
              part_time_vacancies?:               false
            )
          end

          it { should eq false }
        end

        context 'with a part time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               false,
              part_time_vacancies?:               true
            )
          end

          it { should eq false }
        end

        context 'with no vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               false,
              part_time_vacancies?:               false
            )
          end

          it { should eq false }
        end
      end
    end

    context 'with a full time course and vacancy' do
      let(:course) do
        double(
          :course,
          full_time_or_part_time?: false,
          full_time?: true,
          part_time?: false
        )
      end
      context 'with a full time vacancy' do
        let(:site_status) do
          double(
            :site_status,
            full_time_and_part_time_vacancies?: false,
            full_time_vacancies?:               true,
            part_time_vacancies?:               false
          )
        end

        it { should eq true }
      end

      context 'with no vacancy' do
        let(:site_status) do
          double(
            :site_status,
            full_time_and_part_time_vacancies?: false,
            full_time_vacancies?:               false,
            part_time_vacancies?:               false
          )
        end

        it { should eq false }
      end
    end

    context 'with a part time course' do
      let(:course) do
        double(
          :course,
          full_time_or_part_time?: false,
          full_time?: false,
          part_time?: true
        )
      end

      context 'with a part time vacancy' do
        let(:site_status) do
          double(
            :site_status,
            full_time_and_part_time_vacancies?: false,
            full_time_vacancies?:               false,
            part_time_vacancies?:               true
          )
        end

        it { should eq true }
      end

      context 'with no vacancy' do
        let(:site_status) do
          double(
            :site_status,
            full_time_and_part_time_vacancies?: false,
            full_time_vacancies?:               false,
            part_time_vacancies?:               false
          )
        end

        it { should eq false }
      end
    end
  end
end
