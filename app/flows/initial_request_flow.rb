class InitialRequestFlow
  include Rails.application.routes.url_helpers

  PE_SUBJECT_CODE = "C6".freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def template
    if check_your_information_page?
      "providers/allocations/check_your_information"
    elsif number_of_places_page?
      "providers/allocations/number_of_places"
    elsif blank_search_query? || empty_search_results?
      "providers/allocations/initial_request"
    elsif pick_a_provider_page?
      "providers/allocations/pick_a_provider"
    else
      "providers/allocations/initial_request"
    end
  end

  def locals
    if number_of_places_page? || check_your_information_page?
      {
        training_provider: training_provider,
      }
    elsif blank_search_query? || empty_search_results?
      {
        training_providers: training_providers_without_associated,
        form_object: form_object,
      }
    elsif pick_a_provider_page?
      {
        training_providers: training_providers_from_query_without_associated,
      }
    else
      {
        training_providers: training_providers_without_associated,
        form_object: form_object,
      }
    end
  end

  def redirect?
    (training_provider_search? && one_search_result?) || training_provider_selected?
  end

  def redirect_path
    if training_provider_selected?
      initial_request_provider_recruitment_cycle_allocations_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        training_provider_code: params[:training_provider_code],
      )
    else
      initial_request_provider_recruitment_cycle_allocations_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        training_provider_code: training_provider[:provider_code],
      )
    end
  end

  delegate :valid?, to: :form_object

private

  def training_provider_selected?
    params[:training_provider_code].present? && params[:training_provider_code] != "-1"
  end

  def training_provider_search?
    params[:training_provider_code] == "-1" && params[:training_provider_query].present? && params[:training_provider_query].size > 1
  end

  def one_search_result?
    training_providers_from_query_without_associated.count == 1
  end

  def form_object
    permitted_params = params.slice(:training_provider_code, :training_provider_query)
                             .permit(:training_provider_code, :training_provider_query)

    @form_object ||= InitialRequestForm.new(permitted_params)
  end

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
    @training_providers_with_previous_allocations ||= allocations.map(&:provider)
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

  def training_providers_from_query
    return @training_providers_from_query if @training_providers_from_query

    query = params[:training_provider_query]
    @training_providers_from_query ||= ProviderSuggestion.suggest(query)
  end

  def training_providers_from_query_without_associated
    ids_to_reject = associated_training_providers.map(&:id)

    training_providers_from_query.reject do |r|
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

  def empty_search_results?
    return @empty_search_results if @empty_search_results

    @empty_search_results = training_provider_search? && training_providers_from_query_without_associated.empty?

    form_object.add_no_results_error if @empty_search_results

    @empty_search_results
  end

  def pick_a_provider_page?
    training_provider_search? && training_providers_from_query_without_associated.count > 1
  end

  def number_of_places_page?
    training_provider_selected? ||
      (params[:training_provider_query].present? && params[:training_provider_query].size > 1 && one_search_result?) || params[:change]
  end

  def check_your_information_page?
    training_provider_selected? && params[:number_of_places].present? && !params[:change]
  end

  def training_provider
    @training_provider ||= if params[:training_provider_code] == "-1"
                             training_providers_from_query_without_associated.first
                           else
                             Provider
                               .where(recruitment_cycle_year: recruitment_cycle.year)
                               .find(params[:training_provider_code])
                               .first
                           end
  end

  def blank_search_query?
    params[:training_provider_code] == "-1" && params[:training_provider_query].blank?
  end
end
