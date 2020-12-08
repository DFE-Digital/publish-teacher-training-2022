require "rails_helper"

describe SignInController, type: :controller do
  describe "#index" do
    before do
      allow(Settings.features).to receive(:signin_intercept)
        .and_return(signin_intercept)
    end
    context "signin_intercept is false" do
      let(:signin_intercept) { false }

      it "renders the index page" do
        get :index
        expect(response).to render_template("sign_in/index")
      end
    end

    context "signin_intercept is true" do
      let(:signin_intercept) { true }

      it "renders the dfe_sign_in_is_down page" do
        get :index
        expect(response).to render_template("sign_in/dfe_sign_in_is_down")
      end
    end
  end
end
