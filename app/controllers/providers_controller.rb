class ProvidersController < ApplicationController
  before_action :authenticate

  def index
    @providers = Provider.all
  end
end
