class ProvidersController < ApplicationController
  before_action :build_recruitment_cycles, only: %i[show]
  rescue_from JsonApiClient::Errors::NotFound, with: :not_found

  def index
    @providers = Provider.all
    render_manage_ui if @providers.empty?
    redirect_to provider_path(@providers.first.provider_code) if @providers.size == 1
  end

  def show
    @provider = Provider.find(params[:code]).first
  end

  def build_recruitment_cycles
    @current_recruitment_cycle = RecruitmentCycle.new(Settings.current_cycle)
    @next_recruitment_cycle = RecruitmentCycle.new(Settings.current_cycle + 1)
  end
end
