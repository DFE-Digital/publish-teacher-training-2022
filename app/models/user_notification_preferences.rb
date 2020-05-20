class UserNotificationPreferences < Base
  belongs_to :user, shallow_path: true

  property :enabled
  property :updated_at

  def explicitly_enabled
    return nil if updated_at.blank?

    enabled
  end
end
