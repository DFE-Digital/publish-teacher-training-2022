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
      let(:user_email) { "email@example.com" }

      let(:user_info) do
        {
          "first_name" => "John",
          "last_name" => "Smith",
          "email" => user_email,
        }
      end

      let(:payload) { { email: user_email.to_s } }

      let(:user_id) { nil }

      before do
        allow(Base).to receive(:connection)

        allow(JWT).to receive(:encode)
          .with(payload, Settings.authentication.secret, Settings.authentication.algorithm)
          .and_return("anything")

        controller.request.session = { auth_user: { "info" => user_info } }
      end

      context 'user_id is not blank' do
        let(:user_id) { 666 }

        before do
          allow(Session).to receive(:create)

          controller.request.session = { auth_user: { "info" => user_info, :user_id => user_id } }
          controller.authenticate
        end

        it "has performed jwt encoding" do expect(JWT).to have_received(:encode) end
        it "has set connection" do expect(Base).to have_received(:connection) end
        it "has not called session create" do expect(Session).to_not have_received(:create) end
        it "has set user_id" do expect(controller.request.session[:auth_user][:user_id]).to eq user_id end
      end

      context 'user_id is blank' do
        let(:user_info) {
          {
            "first_name" => "John",
            "last_name" => "Smith",
            "email" => user_email,
          }
        }

        before do
          allow(Session).to receive(:create)
            .with(first_name: user_info[:first_name], last_name: user_info[:last_name])
            .and_return(double(id: 999))
          controller.authenticate
        end

        it "has performed jwt encoding" do expect(JWT).to have_received(:encode) end
        it "has set connection" do expect(Base).to have_received(:connection) end
        it "has called session create" do expect(Session).to have_received(:create) end
        it "has set user_id" do expect(controller.request.session[:auth_user][:user_id]).to eq 999 end
      end
    end
  end
end
