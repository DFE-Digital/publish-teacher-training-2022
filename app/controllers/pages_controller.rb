class PagesController < ApplicationController
  before_action :authenticate

  def home; end

  def show
    render template: "pages/#{params[:page]}"
  end
end
