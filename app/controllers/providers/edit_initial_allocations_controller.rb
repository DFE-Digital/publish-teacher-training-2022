module Providers
  class EditInitialAllocationsController < ApplicationController
    def edit
      flow = EditInitialRequestFlow.new(params: params)

      if request.post? && flow.valid?
        redirect_to flow.redirect_path
      else
        render flow.template, locals: flow.locals
      end
    end

    def update
      update_allocation

      @allocation = Allocation.includes(:provider, :accredited_body)
                              .find(params[:id])
                              .first

      redirect_to provider_recruitment_cycle_allocation_path(
        provider_code: allocation.accredited_body.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        training_provider_code: allocation.provider.provider_code,
        id: allocation.id,
      )
    end

    def delete
      allocation.destroy

      redirect_to confirm_deletion_provider_recruitment_cycle_allocation_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        training_provider_code: training_provider.provider_code,
      )
    end

    def confirm_deletion
      @allocation = Allocation.new(request_type: AllocationsView::RequestType::DECLINED)
      @training_provider = training_provider
      @provider = provider
      @recruitment_cycle = recruitment_cycle
      render template: "providers/allocations/show"
    end

  private

    def update_allocation
      allocation.number_of_places = params[:number_of_places].to_i
      allocation.set_all_dirty!
      allocation.save
    end

    def training_provider
      return @training_provider if @training_provider

      p = Provider.new(recruitment_cycle_year: recruitment_cycle.year, provider_code: params[:training_provider_code])
      @training_provider = p.show_any(recruitment_cycle_year: recruitment_cycle.year).first
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

    def allocation
      @allocation ||= Allocation.includes(:provider, :accredited_body)
                                .find(params[:id])
                                .first
    end
  end
end
