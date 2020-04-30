class NotificationsController < ApplicationController
  def index; end

  def create
    if params[:consent].nil?
      # TODO: Better Error messages once wired up to API
      flash[:error] = "Please select one option"
      redirect_to notifications_path
      return
    end

    if params.require(:consent).present?
      flash[:success] = "Your notification preferences have been saved."
      redirect_to redirect_to_path
    end
  end

private

  def redirect_to_path
    if params[:provider_code].present?
      provider_path(params[:provider_code])
    else
      root_path
    end
  end
end
