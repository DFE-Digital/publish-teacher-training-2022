require 'rails_helper'

ffeature 'Vacancy helpers', type: :helper do
  describe '#vacancy_available_for_course_site_status' do
    let(:vacancy_study_mode) { nil }
    let(:is_new) { false }

    subject do
      helper.vacancy_available_for_course_site_status?(
        course,
        site_status,
        vacancy_study_mode
      )
    end

    context 'with status as new' do
      let(:is_new) { true }

      let(:course) { double(:course) }
      let(:site_status) do
        double(
          new?: is_new
        )
      end

      it { should eq false }
    end

    context 'with status as not new' do
      context 'with a full time or part time course' do
        let(:course) { double(:course, study_mode: 'full_time_or_part_time') }

        context 'when the vacancy study mode is full time' do
          let(:vacancy_study_mode) { :full_time }

          context 'with a full and part time vacancy' do
            let(:site_status) do
              double(
                :site_status,
                full_time_and_part_time_vacancies?: true,
                full_time_vacancies?:               false,
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               true,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               true,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
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
                part_time_vacancies?:               true,
                new?:                               is_new
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
                part_time_vacancies?:               false,
                new?:                               is_new
              )
            end

            it { should eq false }
          end
        end
      end

      context 'with a full time course and vacancy' do
        let(:course) { double(:course, study_mode: 'full_time') }

        context 'with a full time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               true,
              part_time_vacancies?:               false,
              new?:                               is_new
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
              part_time_vacancies?:               false,
              new?:                               is_new
            )
          end

          it { should eq false }
        end
      end

      context 'with a part time course' do
        let(:course) { double(:course, study_mode: 'part_time') }

        context 'with a part time vacancy' do
          let(:site_status) do
            double(
              :site_status,
              full_time_and_part_time_vacancies?: false,
              full_time_vacancies?:               false,
              part_time_vacancies?:               true,
              new?:                               is_new
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
              part_time_vacancies?:               false,
              new?:                               is_new
            )
          end

          it { should eq false }
        end
      end
    end
  end
end
