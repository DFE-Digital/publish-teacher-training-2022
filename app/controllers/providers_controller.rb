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

  def details
    @errors = flash[:error_summary]
    flash.delete(:error_summary)
  end

  def contact
    show_deep_linked_errors(%i[email telephone website address1 address3 address4 postcode])
  end

  def about
    show_deep_linked_errors(%i[train_with_us train_with_disability])
  end

  def update
    if @provider.update(provider_params)
      flash[:success] = 'Your changes have been saved'
      redirect_to(
        details_provider_recruitment_cycle_path(
          @provider.provider_code,
          @provider.recruitment_cycle_year
        )
      )
    else
      @errors = @provider.errors.messages

      render provider_params["page"].to_sym
    end
  end

  def publish
    if @provider.publish
      flash[:success] = "Your changes have been published."
    else
      flash[:error_summary] = @provider.errors.messages
    end

    redirect_to details_provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
  end

private

  def provider_params
    params.require(:provider).permit(
      :page,
      :train_with_us,
      :train_with_disability,
      :email,
      :telephone,
      :website,
      :address1,
      :address2,
      :address3,
      :address4,
      :postcode,
      :region_code
    )
  end

  def build_provider
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
