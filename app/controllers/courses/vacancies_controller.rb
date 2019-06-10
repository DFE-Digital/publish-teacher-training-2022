module Courses
  class VacanciesController < ApplicationController
    before_action(
      :build_course,
      :build_site_statuses
    )

    def edit; end

    def update
      params.dig(:course, :site_status_attributes)
        &.values&.each do |vacancy_status|
          site_status = find_site_status vacancy_status[:id]
          # Set all site_status.vac_status to 'no_vacancies' if radio button is checked
          site_status.vac_status = if params[:course][:has_vacancies] == 'false'
                                     'no_vacancies'
                                   else
                                     VacancyStatusDeterminationService.call(
                                       vacancy_status_full_time: vacancy_status[:full_time],
                                       vacancy_status_part_time: vacancy_status[:part_time],
                                       course:                   @course
                                     )
                                   end
          site_status.save
        end

      flash[:success] = 'Course vacancies published'
      redirect_to provider_courses_path(params[:provider_code])
    end

  private

    def build_course
      @course = Course.includes(site_statuses: [:site]).where(provider_code: params[:provider_code]).find(params[:code]).first
    end

    def build_site_statuses
      @site_statuses = @course.site_statuses.select(&:running?)
    end

    def find_site_status(id)
      @site_statuses.find { |site_status_by_id| site_status_by_id.id == id }
    end
  end
end
