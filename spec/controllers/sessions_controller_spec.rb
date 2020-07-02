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
end
