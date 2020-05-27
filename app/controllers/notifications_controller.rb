class NotificationsController < ApplicationController
  def index
    @notifications_view = NotificationsView.new(
      request: request,
      current_user: current_user,
      user_notification_preferences: user_notification_preferences,
    )
  end

  def update
    if params[:user_notification_preferences][:explicitly_enabled].nil?
      flash[:error] = {
        id: "user-notification-preferences-explicitly-enabled-field",
        message: "Please select one option",
      }
      redirect_to notifications_path
      return
    end

    user_notification_preferences.update(
      enabled: params[:user_notification_preferences][:explicitly_enabled],
    )
    flash[:success] = "Your notification preferences have been saved."
    redirect_to redirect_to_path
  end

private

  def redirect_to_path
    if params[:user_notification_preferences][:provider_code].present?
      provider_path(params[:user_notification_preferences][:provider_code])
    else
      root_path
    end
  end

  def user_notification_preferences
    @user_notification_preferences ||= UserNotificationPreferences.find(current_user["user_id"]).first
  end
end
