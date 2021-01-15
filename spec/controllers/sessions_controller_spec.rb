require "rails_helper"

describe SessionsController, type: :controller do
  describe "#signout" do
    context "when using developer auth", authentication_mode: :persona do
      before do
        allow(Settings.authentication.basic_auth).to receive(:disabled).and_return(true)

        session[:auth_user] = {
          "provider" => "developer",
          "uid" => "user@example.com",
          "user_id" => "some-id",
          "info" => {
            "email" => "user@example.com",
          },
        }
      end

      it "resets the session" do
        get :signout
        expect(session[:auth_user]).to be_nil
      end

      it "redirects to /personas login page" do
        get :signout
        expect(response).to redirect_to("/personas")
      end
    end

    context "when using magic link", authentication_mode: :magic_link do
      before do
        session[:auth_user] = {
          "uid" => "user@example.com",
          "user_id" => "some-id",
          "info" => {
            "email" => "user@example.com",
          },
        }
      end

      it "resets the session" do
        get :signout
        expect(session[:auth_user]).to be_nil
      end

      it "redirects to /" do
        get :signout
        expect(response).to redirect_to("/")
      end
    end
  end
end
