module Courses
  class VacanciesController < ApplicationController
    before_action :authenticate, :get_course

    def edit; end

    def update
      course = Course.where(provider_code: params[:provider_code]).find(params[:code])
      site_statuses = course.map(&:site_statuses).flatten

      params[:course][:site_status_attributes].values.each do |vac_status|
        site_status = site_statuses.find { |site_status| site_status.id == vac_status[:id] }

        site_status.vac_status = if vac_status[:vac_status_full_time] == "0" && vac_status[:vac_status_part_time] == "1"
                                   "part_time_vacancies"
                                 elsif vac_status[:vac_status_full_time] == "1" && vac_status[:vac_status_part_time] == "0"
                                   "full_time_vacancies"
                                 elsif vac_status[:vac_status_full_time] == "1" && vac_status[:vac_status_part_time] == "1"
                                   "both_full_time_and_part_time_vacancies"
                                 elsif vac_status[:vac_status_full_time] == "0" && vac_status[:vac_status_part_time] == "0"
                                   "no_vacancies"
        end

        site_status.save
      end
      redirect_to vacancies_provider_course_path(@course.course_code)
    end

  private

    def get_course
      @course = Course.where(provider_code: params[:provider_code]).find(params[:code]).first
    end
  end
end
