require "rails_helper"

describe SignInController, type: :controller do
  describe "#index" do
    context "when mode is non_magic", authentication_mode: :non_magic do
      it "renders the index page" do
        get :index
        expect(response).to render_template("sign_in/index")
      end
    end

    context "when mode is magic", authentication_mode: :magic do
      it "renders the dfe_sign_in_is_down page" do
        get :index
        expect(response).to render_template("sign_in/dfe_sign_in_is_down")
      end
    end
  end
end
