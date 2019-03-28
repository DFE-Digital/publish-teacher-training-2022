module Courses
  class VacanciesController < ApplicationController
    before_action(
      :authenticate,
      :build_course,
      :build_site_statuses,
      :build_first_course
    )

    def edit; end

    def update
      params.dig(:course, :site_status_attributes)
        &.values&.each do |vacancy_status|
          site_status            = find_site_status vacancy_status[:id]
          site_status.vac_status = VacancyStatusDeterminationService.call(
            vacancy_status_full_time: vacancy_status[:full_time],
            vacancy_status_part_time: vacancy_status[:part_time],
            course:                   @course
          )
          site_status.save
        end

      flash[:success] = 'Course vacancies published'
      redirect_to vacancies_provider_course_path(params[:provider_code], @course.course_code)
    end

  private

    def build_course
      @course = Course.where(provider_code: params[:provider_code]).find(params[:code])
    end

    def build_site_statuses
      @site_statuses = @course.map(&:site_statuses).flatten
    end

    def build_first_course
      @course = @course.first
    end

    def find_site_status(id)
      @site_statuses.find { |site_status_by_id| site_status_by_id.id == id }
    end
  end
end
