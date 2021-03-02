module AdminOnlyMaintenanceMode
  extend ActiveSupport::Concern
  include ActionView::Helpers::TextHelper

  included do
    before_action :redirect_non_admins_in_maintenance_mode
  end

private

  def redirect_non_admins_in_maintenance_mode
    return unless Settings.features.maintenance_mode.enabled

    flash[:notice] = simple_format(Settings.features.maintenance_mode.message)

    return if %w[sign_in sessions].include?(controller_name)

    unless current_user && current_user["admin"]
      redirect_to sign_in_path
    end
  end
end
