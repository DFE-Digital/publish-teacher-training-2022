class EditInitialRequestFlow
  include Rails.application.routes.url_helpers

  attr_reader :params
  delegate :valid?, to: :form_object

  def initialize(params:)
    @params = params
  end

  def template
    if proceed_to_check_answers_page?
      "providers/edit_initial_allocations/check_answers"
    elsif proceed_to_number_of_places_page?
      "providers/edit_initial_allocations/number_of_places"
    else
      "providers/edit_initial_allocations/do_you_want"
    end
  end

  def locals
    if proceed_to_check_answers_page? || proceed_to_number_of_places_page?
      {
        training_provider: training_provider,
        provider: provider,
        form_object: form_object,
        recruitment_cycle: recruitment_cycle,
        allocation: allocation,
      }
    else
      {
        training_provider: training_provider,
        allocation: allocation,
        provider: provider,
        form_object: form_object,
      }
    end
  end

  def redirect_path
    if proceed_to_check_answers_page? || accepted_initial_allocation?
      get_edit_initial_request_provider_recruitment_cycle_allocation_path(
        provider_code: allocation.accredited_body.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        training_provider_code: allocation.provider.provider_code,
        number_of_places: params[:number_of_places],
        next_step: params[:next_step],
        id: allocation.id,
        request_type: params[:request_type],
      )
    else
      delete_initial_request_provider_recruitment_cycle_allocation_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        training_provider_code: training_provider.provider_code,
        id: allocation.id,
      )
    end
  end

private

  def accepted_initial_allocation?
    params[:next_step] == "number_of_places" && params[:request_type].present? && params[:request_type] == AllocationsView::RequestType::INITIAL
  end

  def number_of_places_validation_error?
    (params[:next_step] == "check_answers" && !form_object.valid?)
  end

  def proceed_to_number_of_places_page?
    params[:next_step] == "number_of_places" && params[:request_type].present? || number_of_places_validation_error?
  end

  def proceed_to_check_answers_page?
    params[:next_step] == "check_answers" && params[:number_of_places].present? && form_object.valid?
  end

  def number_of_places_page?
    (params[:step].present? && params[:step] == "number_of_places") || params[:number_of_places].present?
  end

  def check_answers_page?
    params[:step].present? && params[:step] == "check_answers"
  end

  def training_provider
    return @training_provider if @training_provider

    p = Provider.new(recruitment_cycle_year: recruitment_cycle.year, provider_code: params[:training_provider_code])
    @training_provider = p.show_any(recruitment_cycle_year: recruitment_cycle.year).first
  end

  def allocation
    @allocation ||= Allocation.includes(:provider, :accredited_body)
                              .find(params[:id])
                              .first
  end

  def provider
    @provider ||= Provider
                    .where(recruitment_cycle_year: recruitment_cycle.year)
                    .find(params[:provider_code])
                    .first
  end

  def recruitment_cycle
    return @recruitment_cycle if @recruitment_cycle

    cycle_year = params.fetch(:year, Settings.current_cycle)
    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end

  def form_object
    permitted_params = params
                         .slice(:request_type, :number_of_places)
                         .permit(:request_type, :number_of_places)
    @form_object ||= EditInitialRequestForm.new(permitted_params)
  end
end
