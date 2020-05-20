class UserNotificationPreferencesSerializer < JSONAPI::Serializable::Resource
  type "user_notification_preferences"

  belongs_to :user

  attributes(*FactoryBot.attributes_for("user_notification_preferences").keys)

  attribute :enabled
  attribute :updated_at
end
