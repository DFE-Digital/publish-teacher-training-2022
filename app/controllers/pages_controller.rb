class PagesController < ApplicationController
  before_action :authenticate

  def show
    render template: "pages/#{params[:page]}"
  end
end
