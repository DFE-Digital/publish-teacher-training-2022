module Providers
  class ReferencesController < ApplicationController
    def edit
      @form_object = ProviderReferencesForm.new(provider)
    end

    def update
      @form_object = ProviderReferencesForm.new(provider, params: provider_params)

      if @form_object.save
        redirect_to details_provider_recruitment_cycle_path(provider.provider_code, recruitment_cycle.year)
      else
        render :edit
      end
    end

  private

    def provider
      @provider ||= Provider.where(recruitment_cycle_year: recruitment_cycle.year).find(params[:provider_code]).first
    end

    def recruitment_cycle
      @recruitment_cycle ||= RecruitmentCycle.find(params[:recruitment_cycle_year]).first
    end

    def provider_params
      params.require(:provider_references_form).permit(*ProviderReferencesForm::FIELDS)
    end
  end
end
