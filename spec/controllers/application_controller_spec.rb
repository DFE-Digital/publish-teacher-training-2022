require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  before do
    controller.response = response
  end


  describe '#authenticate' do
  subject { controller.authenticate }

    context 'user is unauthenticated' do
      it { should redirect_to '/signin' }
    end

    context 'user is authenticated' do
      user_email = "email@example.com"
      before do
        allow(Base).to receive(:connection)

        payload = { email: user_email.to_s }

        allow(JWT).to receive(:encode)
        .with(payload.to_json, Settings.authentication.secret,Settings.authentication.algorithm)
        .and_return("anything")

        controller.request.session = {:auth_user => {"info" => {
          "first_name" => "John",
          "last_name" => "Smith",
          "email" => user_email
        }}}
      end

      it "sets encoded payload for connection" do
        act =  controller.authenticate
        expect(JWT).to have_received(:encode)
        expect(Base).to have_received(:connection)
      end
    end
  end
end
