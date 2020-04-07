class PeAllocationsController < ApplicationController
  before_action :build_recruitment_cycle
  before_action :build_provider
  before_action :require_provider_to_be_accredited_body!

  def index; end

private

  def build_provider
    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def build_recruitment_cycle
    cycle_year = params.fetch(:year, Settings.current_cycle)

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end

  def require_provider_to_be_accredited_body!
    render "errors/not_found", status: :not_found unless @provider.accredited_body?
  end
end
