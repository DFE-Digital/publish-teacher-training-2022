class SitesController < ApplicationController
  before_action :authenticate, :build_provider

  def index
    @sites = @provider.sites.sort_by(&:location_name)
  end

  def edit
    @site = Site.where(provider_code: params[:provider_code]).find(params[:id]).first
  end

private

  def build_provider
    @provider = Provider.includes(:sites).find(params[:provider_code]).first
  end
end
