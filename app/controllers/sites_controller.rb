class SitesController < ApplicationController
  before_action :authenticate

  def index
    @provider = Provider.includes(:sites).find(params[:provider_code]).first
    @sites = @provider.sites.sort_by(&:location_name)
  end
end
