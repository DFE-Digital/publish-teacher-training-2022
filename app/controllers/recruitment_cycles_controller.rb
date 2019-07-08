class RecruitmentCyclesController < ApplicationController
  def show
    @recruitment_cycle = RecruitmentCycle.new(params[:year])
    @provider = Provider.find(params[:provider_code]).first

    if !@provider.rolled_over?
      redirect_to provider_path(@provider.provider_code)
    end
  end
end
