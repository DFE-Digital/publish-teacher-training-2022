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

      @allocation_statuses = [
        { status: "YET TO REQUEST", status_colour: "grey" },
        { status: "NOT REQUESTED", status_colour: "red", requested: "no" },
        { status: "REQUESTED", status_colour: "green", requested: "yes" },
      ]
    end

    def new; end

    def create
      if params.require(:requested) == "Yes"
        redirect_to provider_recruitment_cycle_allocation_path(requested: "yes")
      else
        redirect_to provider_recruitment_cycle_allocation_path(requested: "no")
      end
    end

    def show
      if params[:requested] == "yes"
        @allocation = Allocation.new(number_of_places: 42)
      end

      if params[:requested] == "no"
        @allocation = Allocation.new(number_of_places: 0)
      end
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
  end
end
