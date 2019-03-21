class ProvidersController < ApplicationController
  before_action :authenticate

  def index
    @providers = Provider.all
    render_manage_ui if @providers.empty?
    redirect_to provider_path(@providers.first.institution_code) if @providers.size == 1
  end

  def show
    provider_count = session.try(:[], :auth_user).try(:[], :provider_count)
    @has_multiple_providers = provider_count.nil? || provider_count > 1
    @provider = Provider.find(params[:code]).first.attributes
  end
end
