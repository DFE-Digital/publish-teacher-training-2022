require "rails_helper"

describe NotificationsController, type: :controller do
  let(:current_user) do
    {
      user_id: 1,
      uid: SecureRandom.uuid,
      info: {
        email: "dave@example.com",
      },
    }.with_indifferent_access
  end

  let(:user) { build(:user, :notifications_configured, id: 1) }

  describe "UPDATE" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
                                                        .and_return(current_user)

      user_notification_preferences = instance_double(UserNotificationPreferences)
      allow(user_notification_preferences).to receive(:update).and_return(user_notification_preferences)
      allow(UserNotificationPreferences).to receive(:find).and_return([user_notification_preferences])
      stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)
    end

    context "params[:provider_code] not present" do
      it "redirects to the root path" do
        params = {
          user_notification_preferences: {
            explicitly_enabled: true,
          },
          id: current_user[:user_id],
        }

        put :update, params: params
        expect(response).to redirect_to(root_path)
      end
    end

    context "params[:provider_code] is present" do
      it "redirects to the provider_path" do
        provider_code = "A1"
        params = {
          user_notification_preferences: {
            explicitly_enabled: true,
            provider_code: provider_code,
          },
          id: current_user[:user_id],
        }

        put :update, params: params
        expect(response).to redirect_to(provider_path(provider_code))
      end
    end
  end
end
