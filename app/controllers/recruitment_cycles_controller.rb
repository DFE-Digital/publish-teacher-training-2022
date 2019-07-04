class RecruitmentCyclesController < ApplicationController
  def show
    redirect_to provider_recruitment_cycle_courses_path(params[:provider_code], '2019')
  end
end
