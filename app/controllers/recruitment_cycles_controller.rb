class RecruitmentCyclesController < ApplicationController
  def show
    @recruitment_cycle = RecruitmentCycle.find(params[:year]).first
    @provider = Provider.where(recruitment_cycle_year: params[:year])
      .find(params[:provider_code])
      .first

    if params[:year] == Settings.current_cycle.to_s
      redirect_to provider_path(@provider.provider_code)
    end
  end
end
