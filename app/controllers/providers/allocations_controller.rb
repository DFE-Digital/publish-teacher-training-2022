module Providers
  class AllocationsController < ApplicationController
    before_action :build_recruitment_cycle
    before_action :build_provider
    before_action :require_provider_to_be_accredited_body!
    before_action :require_admin_permissions!

    def index; end

  private

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
  end
end