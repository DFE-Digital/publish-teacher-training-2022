module Providers
  class AllocationsController < ApplicationController
    before_action :build_recruitment_cycle
    before_action :build_provider
    before_action :build_training_provider, except: %i[index initial_request]
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
        number_of_places: params[:number_of_places],
      )

      redirect_to provider_recruitment_cycle_allocation_path(
        requested: (params[:requested].downcase unless initial_request?),
        number_of_places: params[:number_of_places],
      )
    end

    def show
      # TODO: temp until we retrieve the Allocation from the API
      @allocation = Allocation.new(
        number_of_places: number_of_places,
        request_type: (Allocation::RequestTypes::INITIAL if initial_request?),
      )
    end

    def initial_request
      flow = InitialRequestFlow.new(params: params)

      render flow.template, locals: flow.locals
    end

  private

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
      initial_request? || params[:requested].downcase == "yes"
    end

    def initial_request?
      params[:number_of_places].present?
    end

    def number_of_places
      if initial_request?
        params[:number_of_places]
      else
        requested? ? 42 : 0
      end
    end
  end
end
