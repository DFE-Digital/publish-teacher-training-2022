require "rails_helper"

describe SessionsController, type: :controller do
  context "signin is disabled" do
    before do
      allow(Settings.features).to receive(:dfe_signin)
        .and_return(false)
    end

    describe "new" do
      it "renders the new session page" do
        get :new
        expect(response).to render_template("sessions/new")
      end
    end

    describe "create" do
      it "redirects to /signin" do
        get :create
        expect(response).to redirect_to(signin_path)
      end
    end
  end

  context "signin is enabled" do
    before do
      allow(Settings.features).to receive(:dfe_signin)
        .and_return(true)
    end

    describe "new" do
      it "redirects to signin" do
        get :new
        expect(response).to redirect_to("/auth/dfe")
      end
    end
  end

  context "when developer auth is enabled" do
    describe "#new" do
      it "redirects to personas login" do
        allow(Settings).to receive(:developer_auth).and_return(true)
        get :new
        expect(response).to redirect_to("/personas")
      end
    end
  end

  describe "#signout" do
    context "when using developer auth" do
      before do
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
  end
end
