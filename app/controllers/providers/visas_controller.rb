module Providers
  class VisasController < ApplicationController
    def edit
      @form_object = ProviderVisaForm.new(
        can_sponsor_skilled_worker_visa: provider.can_sponsor_skilled_worker_visa,
        can_sponsor_student_visa: provider.can_sponsor_student_visa,
      )
    end

    def update
      @form_object = ProviderVisaForm.new(
         can_sponsor_skilled_worker_visa: params[:can_sponsor_skilled_worker_visa],
         can_sponsor_student_visa: params[:can_sponsor_student_visa],
      )
      if @form_object.save
        redirect_to details_provider_recruitment_cycle_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
        )
      else
        provider
        render :edit
      end
    end

  private

    def provider
      @provider ||= Provider
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .find(params[:provider_code])
        .first
    end
  end
end
