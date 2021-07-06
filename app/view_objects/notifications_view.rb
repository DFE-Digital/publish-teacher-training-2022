class NotificationsView
  ORGANISATION_URL_PATTERN = /\/organisations\/(\S+)\/?/.freeze

  attr_reader :user_notification_preferences

  def initialize(
    request:,
    current_user:,
    user_notification_preferences:
  )
    @request = request
    @current_user = current_user
    @user_notification_preferences = user_notification_preferences
  end

  def user_id
    current_user["user_id"]
  end

  def user_email
    current_user["info"]["email"]
  end

  def back_link_path
    return Rails.application.routes.url_helpers.root_path if ORGANISATION_URL_PATTERN.match(request.referer).nil?

    URI(request.referer).path
  end

  def provider_code
    matches = ORGANISATION_URL_PATTERN.match(request.referer)
    return if matches.nil?

    matches[1]
  end

private

  attr_reader :request, :current_user
end
