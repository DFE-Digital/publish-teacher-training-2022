module Courses
  class VacanciesController < ApplicationController
    before_action(
      :build_course,
      :build_site_statuses,
    )

    def edit; end

    def update
      unless params[:change_vacancies_confirmation]
        set_missing_confirmation_error
        return render(:edit)
      end

      @course.has_multiple_running_sites_or_study_modes? ? update_vacancies_for_multiple_sites : update_vacancies_for_a_single_site
      flash[:success] = "Course vacancies published"
      redirect_to provider_recruitment_cycle_courses_path(params[:provider_code], params[:recruitment_cycle_year])
    end

  private

    def set_missing_confirmation_error
      error_message = if @course.has_vacancies?
                        "Please confirm there are no vacancies to close applications"
                      else
                        "Please confirm there are vacancies to reopen applications"
                      end

      @errors = { change_vacancies_confirmation: [error_message] }
    end

    def update_vacancies_for_a_single_site
      case params[:change_vacancies_confirmation]
      when "no_vacancies_confirmation"
        vac_status = "no_vacancies"
      when "has_vacancies_confirmation"
        vac_status = @course.full_time? ? "full_time_vacancies" : "part_time_vacancies"
      end

      @site_statuses.each do |site_status|
        site_status.vac_status = vac_status
        site_status.recruitment_cycle_year = @course.recruitment_cycle_year
        site_status.save
      end
    end

    def update_vacancies_for_multiple_sites
      params.dig(:course, :site_status_attributes)
        &.values&.each do |vacancy_status|
          site_status = find_site_status vacancy_status[:id]
          # Set all site_status.vac_status to 'no_vacancies' if radio button is checked
          site_status.vac_status = if params[:course][:has_vacancies] == "false"
                                     "no_vacancies"
                                   else
                                     VacancyStatusDeterminationService.call(
                                       vacancy_status_full_time: vacancy_status[:full_time],
                                       vacancy_status_part_time: vacancy_status[:part_time],
                                       course:                   @course,
                                     )
                                   end
          site_status.save
        end
    end

    def build_course
      @course = Course
        .includes(site_statuses: [:site])
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
    end

    def build_site_statuses
      @site_statuses = @course.running_site_statuses
    end

    def find_site_status(id)
      @site_statuses.find { |site_status_by_id| site_status_by_id.id == id }
    end
  end
end
