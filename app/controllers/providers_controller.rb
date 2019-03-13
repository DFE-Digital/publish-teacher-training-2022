class ProvidersController < ApplicationController
  before_action :authenticate

  def index
    @providers = Provider.all
    render_manage_ui if @providers.empty?
  end

  def show
    @provider = Provider.find(params[:code]).first.attributes
  end
end
