class RecruitmentCyclesController < ApplicationController
  def show
    @recruitment_cycle = RecruitmentCycle.find(params[:year]).first
    @provider = Provider.where(recruitment_cycle_year: params[:year])
      .find(params[:provider_code])
      .first

    unless @provider.rolled_over?
      redirect_to provider_path(@provider.provider_code)
    end
  end
end
