class ProvidersController < ApplicationController
  before_action :authenticate

  def index
    @providers = Provider.all
  end

  def show
    @provider = Provider.where(institution_code: params[:id]).first
  end
end
