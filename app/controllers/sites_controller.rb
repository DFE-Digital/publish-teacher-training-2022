class SitesController < ApplicationController
  before_action :authenticate

  def index
    @provider = Provider.includes(:sites).find(params[:provider_code]).first
    @sites = @provider.sites
  end
end
