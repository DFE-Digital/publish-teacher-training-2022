module Providers
  class AllocationsController < ApplicationController
    before_action :build_recruitment_cycle
    before_action :build_provider
    before_action :build_training_provider, except: %i[index]
    before_action :require_provider_to_be_accredited_body!
    before_action :require_admin_permissions!

    PE_SUBJECT_CODE = "C6".freeze

    def index
      @training_providers = @provider.training_providers(
        recruitment_cycle_year: @recruitment_cycle.year,
        "filter[subjects]": PE_SUBJECT_CODE,
        "filter[funding_type]": "fee",
      )

      allocations = Allocation
                      .includes(:provider, :accredited_body)
                      .where(provider_code: params[:provider_code])
                      .all

      @allocations_view = AllocationsView.new(
        allocations: allocations, training_providers: @training_providers,
      )
    end

    def repeat_request; end

    def create
      # TODO: we need to add error handling here
      AllocationServices::Create.call(
        accredited_body_code: @provider.provider_code,
        provider_id: @training_provider.id,
        requested: requested?,
      )

      redirect_to provider_recruitment_cycle_allocation_path(requested: params[:requested].downcase)
    end

    def show
      # TODO: temp until we retrieve the Allocation from the API
      number_of_places = requested? ? 42 : 0
      @allocation = Allocation.new(number_of_places: number_of_places)
    end

    def initial_request
      get_training_providers_without_previous_allocations

      if params[:training_provider_code]
        render "providers/allocations/places"
      end
    end

  private

    def get_training_providers_without_previous_allocations
      training_providers_with_previous_allocations = @provider.training_providers(
        recruitment_cycle_year: @recruitment_cycle.year,
        "filter[subjects]": PE_SUBJECT_CODE,
        "filter[funding_type]": "fee",
      )

      @training_providers_without_previous_allocations =
        @provider.training_providers(
          recruitment_cycle_year: @recruitment_cycle.year,
        ).reject do |provider|
          training_providers_with_previous_allocations
           .map(&:provider_code).include?(provider.provider_code)
        end
    end

    def build_training_provider
      @training_provider = Provider
       .where(recruitment_cycle_year: @recruitment_cycle.year)
       .find(params[:training_provider_code])
       .first
    end

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

    def require_admin_permissions!
      render "errors/forbidden", status: :forbidden unless user_is_admin?
    end

    def requested?
      params[:requested].downcase == "yes"
    end
  end
end
