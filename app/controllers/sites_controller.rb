class SitesController < ApplicationController
  before_action :build_provider, :build_recruitment_cycle
  before_action :build_site, only: %i[edit update]

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params.to_h)
    @site.recruitment_cycle_year = @provider.recruitment_cycle_year
    @site.provider_code = @provider.provider_code

    if @site.save
      redirect_to provider_recruitment_cycle_sites_path(@site.provider_code), flash: { success: "Your location has been created" }
    else
      @errors = @site.errors.messages

      render :new
    end
  end

  def index
    @sites = @provider.sites.sort_by(&:location_name)
  end

  def edit; end

  def update
    # We don't have a provider_code in the backend, only provider_id, and this
    # is required in order to run #update.
    @site.provider_code = @provider.provider_code

    if @site.update(site_params)
      redirect_to provider_recruitment_cycle_sites_path(@site.provider_code, @site.recruitment_cycle_year), flash: { success: "Your changes have been published" }
    else
      @errors = @site.errors.messages

      render :edit
    end
  end

private

  def build_site
    @site = @provider.sites.find { |site| site.id == params[:id] }

    if @site
      @site_name_before_update = @site.location_name.dup
    else
      render template: "errors/not_found", status: :not_found
    end
  end

  def build_provider
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )

    @provider = Provider
      .includes(:sites)
      .where(recruitment_cycle_year: cycle_year)
      .find(params[:provider_code])
      .first
  end

  def build_recruitment_cycle
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end

  def site_params
    params.require(:site).permit(
      :location_name,
      :address1,
      :address2,
      :address3,
      :address4,
      :postcode,
      :region_code,
    )
  end
end
