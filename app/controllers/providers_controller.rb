class ProvidersController < ApplicationController
  decorates_assigned :provider
  decorates_assigned :training_provider
  before_action :build_recruitment_cycle
  rescue_from JsonApiClient::Errors::NotFound, with: :not_found
  before_action :build_provider, except: %i[index show]
  before_action :build_training_provider, only: %i[training_provider_courses]

  def index
    @providers = Kaminari.paginate_array(Provider.where(recruitment_cycle_year: Settings.current_cycle).all)
                          .page(params[:page] || 1).per(params[:per_page] || 10)

    render "providers/no_providers", status: :forbidden if @providers.empty?
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
      flash[:success] = "Your changes have been published"
      redirect_to(
        details_provider_recruitment_cycle_path(
          @provider.provider_code,
          @provider.recruitment_cycle_year,
        ),
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

  def training_providers
    if user_is_admin?
      @training_providers = @provider.training_providers(recruitment_cycle_year: @recruitment_cycle.year)
    else
      redirect_to provider_path(@provider.provider_code)
    end
  end

  def training_provider_courses
    if user_is_admin?
      @courses = @training_provider.courses
        .filter { |course| course[:accrediting_provider].present? }
        .select { |course| course[:accrediting_provider][:provider_code] == @provider.provider_code }
        .map(&:decorate)
    else
      redirect_to provider_path(@training_provider.provider_code)
    end
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
      :region_code,
      accredited_bodies: %i[provider_name provider_code description],
    ).to_h # Without this, accredited_bodies is an array of params objects
           # instead of an array of plain hashes and gets serialized incorrectly
           # on its way to the backend.
  end

  def build_provider
    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def build_training_provider
    @training_provider = Provider
      .includes(courses: [:accrediting_provider])
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:training_provider_code])
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
