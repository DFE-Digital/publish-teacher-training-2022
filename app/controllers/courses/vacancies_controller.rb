module Courses
  class VacanciesController < ApplicationController
    before_action :authenticate, :get_course

    def edit; end

    def update
      course = Course.includes(:site_statuses).where(provider_code: params[:provider_code]).find(params[:code])
      site_statuses = course.map(&:site_statuses).flatten

      params[:course][:site_status_attributes].values.each do |vac_status|
        site_status = site_statuses.find{|site_status| site_status.id == vac_status[:id]}
        vacancy_status = "no_vacancies" #TODO figure this out
        site_status.vac_status = vacancy_status
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
