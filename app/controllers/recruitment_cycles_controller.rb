class RecruitmentCyclesController < ApplicationController
  def show
    @recruitment_cycle = RecruitmentCycle.new(params[:year])
    @provider = Provider.find(params[:provider_code]).first

    if !@provider.rolled_over?
      redirect_to provider_recruitment_cycle_courses_path(@provider.provider_code, '2019')
    end
  end
end
