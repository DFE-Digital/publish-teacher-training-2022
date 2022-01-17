module Providers
  class VisasController < ApplicationController
    def edit
      redirect_to_new_publish_url_provider_recruitment_cycle_visas_path if FeatureService.enabled?("new_publish.about_your_org")

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
      if @form_object.save(provider)
        redirect_to details_provider_recruitment_cycle_path(
          provider.provider_code,
          recruitment_cycle.year,
        )
      else
        render :edit
      end
    end

  private

    def redirect_to_new_publish_url_provider_recruitment_cycle_visas_path
      redirect_to new_publish_url(provider_recruitment_cycle_visas_path(provider.provider_code, provider.recruitment_cycle_year))
    end

    def provider
      @provider ||= Provider
        .where(recruitment_cycle_year: recruitment_cycle.year)
        .find(params[:provider_code])
        .first
    end

    def recruitment_cycle
      @recruitment_cycle ||= RecruitmentCycle.find(params[:recruitment_cycle_year]).first
    end
  end
end
