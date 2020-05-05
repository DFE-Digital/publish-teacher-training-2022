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
      flow = InitialRequestFlow.new(params: params)

      render flow.template, locals: flow.locals
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
      return if params[:training_provider_code].blank?

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

class InitialRequestFlow
  PE_SUBJECT_CODE = "C6".freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def template
    if associated_training_providers_page?
      "providers/allocations/pick_a_provider"
    elsif select_training_providers_from_search_page?
      "providers/allocations/places"
    else
      "initial_request"
    end
  end

  def locals
    if associated_training_providers_page?
      {
        training_providers: training_providers_from_query_without_associated(query: params[:training_provider_query]),
      }
    elsif select_training_providers_from_search_page?
      {}
    else
      {
        training_providers: training_providers_without_associated,
      }
    end
  end

private

  def allocations
    @allocations ||= Allocation.includes(:provider, :accredited_body)
                               .where(provider_code: provider.provider_code)
                               .all
  end

  def training_providers_with_fee_paying_pe_course
    @training_providers_with_fee_paying_pe_course ||= provider.training_providers(
      recruitment_cycle_year: recruitment_cycle.year,
      "filter[subjects]": PE_SUBJECT_CODE,
      "filter[funding_type]": "fee",
    )
  end

  def all_training_providers
    @all_training_providers ||=
      provider.training_providers(
        recruitment_cycle_year: recruitment_cycle.year,
      )
  end

  def training_providers_with_previous_allocations
    @training_providers_with_previous_allocations ||= allocations.map do |allocation|
      Provider.new(id: allocation.provider_id.to_s)
    end
  end

  def associated_training_providers
    training_providers_with_previous_allocations + training_providers_with_fee_paying_pe_course
  end

  def training_providers_without_associated
    return @training_providers_without_associated if @training_providers_without_associated

    ids_to_reject = associated_training_providers.map(&:id)

    @training_providers_without_associated = all_training_providers.reject do |provider|
      ids_to_reject.include?(provider.id)
    end
  end

  def training_providers_from_query(query:)
    ProviderSuggestion.suggest(query)
  end

  def training_providers_from_query_without_associated(query:)
    results = training_providers_from_query(query: query)
    ids_to_reject = associated_training_providers.map(&:id)

    results.reject do |r|
      ids_to_reject.include?(r.id)
    end
  end

  def recruitment_cycle
    return @recruitment_cycle if @recruitment_cycle

    cycle_year = params.fetch(:year, Settings.current_cycle)

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end

  def provider
    @provider ||= Provider
      .where(recruitment_cycle_year: recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def associated_training_providers_page?
    params[:training_provider_code].blank? && params[:training_provider_query].present?
  end

  def select_training_providers_from_search_page?
    params[:training_provider_code]
  end
end
