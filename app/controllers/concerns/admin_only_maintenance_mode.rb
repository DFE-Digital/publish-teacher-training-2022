module AdminOnlyMaintenanceMode
  extend ActiveSupport::Concern
  include ActionView::Helpers::TextHelper

  included do
    before_action :redirect_non_admins_in_maintenance_mode
  end

private

  def redirect_non_admins_in_maintenance_mode
    return unless Settings.features.maintenance_mode.enabled
    return if %w[sign_in sessions].include?(controller_name)

    redirect_if_non_admin
  end

  def redirect_if_non_admin
    unless current_user && current_user["admin"]
      redirect_to sign_in_path
    end
  end
end
