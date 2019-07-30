class ProvidersController < ApplicationController
  decorates_assigned :provider
  before_action :build_recruitment_cycle
  rescue_from JsonApiClient::Errors::NotFound, with: :not_found
  before_action :build_provider, except: %i[index show]

  def index
    @providers = Provider
      .where(recruitment_cycle_year: Settings.current_cycle)
      .all

    render_manage_ui if @providers.empty?
    redirect_to provider_path(@providers.first.provider_code) if @providers.size == 1
  end

  def show
    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:code])
      .first
  end

  def contact; end

  def details; end

  def about; end

private

  def build_provider
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def show_deep_linked_errors(attributes)
    return if params[:display_errors].blank?

    @provider.publishable?
    @errors = @provider.errors.messages.select { |key| attributes.include? key }
  end

  def build_recruitment_cycle
    cycle_year = params.fetch(:year, Settings.current_cycle)

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end
end
