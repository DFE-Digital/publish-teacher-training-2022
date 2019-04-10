class SitesController < ApplicationController
  before_action :authenticate, :build_provider, :initialise_errors
  before_action :build_site, only: %i[edit update]

  def index
    @sites = @provider.sites.sort_by(&:location_name)
  end

  def edit; end

  def update
    # We don't have a provider_code in the backend, only provider_id, and this
    # is required in order to run #update.
    @site.provider_code = @provider.provider_code

    if @site.update(site_params)
      redirect_to provider_sites_path, flash: { success: 'Your changes have been published' }
    else
      @errors = @site.errors.reduce({}) { |errors, (field, message)|
        errors[field] ||= []
        errors[field].push(map_errors(message))
        errors
      }
      render :edit
    end
  end

private

  def build_site
    @site = @provider.sites.find { |site| site.id == params[:id] }
  end

  def build_provider
    @provider = Provider.includes(:sites).find(params[:provider_code]).first
  end

  def site_params
    params.require(:site).permit(
      :location_name,
      :address1,
      :address2,
      :address3,
      :address4,
      :postcode,
      :region_code
    )
  end

  def initialise_errors
    @errors = {}
  end

  def map_errors(message)
    {
      "Location name can't be blank"             => "Name is missing",
      "Address1 can't be blank"                  => "Building and street is missing",
      "Address3 can't be blank"                  => "Town or city is missing",
      "Postcode can't be blank"                  => "Postcode is missing",
      "Postcode not recognised as a UK postcode" => "Postcode is not valid (for example, BN1 1AA)"
    }[message] || message
  end
end
