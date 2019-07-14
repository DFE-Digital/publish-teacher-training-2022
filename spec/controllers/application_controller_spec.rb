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
      let(:sign_in_user_id) { SecureRandom.uuid }

      let(:user_info) do
        {
          "first_name" => "John",
          "last_name" => "Smith",
          "email" => user_email,
        }
      end

      let(:payload) do
        {
          email:           user_email.to_s,
          sign_in_user_id: sign_in_user_id
        }
      end

      before do
        allow(Base).to receive(:connection)

        allow(JWT).to receive(:encode)
          .with(payload, Settings.manage_backend.secret, Settings.manage_backend.algorithm)
          .and_return("anything")
      end

      context 'user_id is not blank' do
        let(:user_id) { 666 }

        before do
          allow(Session).to receive(:create)
          allow(Provider).to receive(:all)
            .and_raise('Could not connect to backend')

          controller.request.session = {
            auth_user: {
              "info"    => user_info,
              'user_id' => user_id,
              'uid'     => sign_in_user_id
            }
          }
          controller.authenticate
        end

        it "has performed jwt encoding" do
          expect(JWT).to have_received(:encode)
        end

        it "has not called session create" do
          expect(Session).to_not have_received(:create)
        end

        it "has set user_id" do
          expect(controller.request.session[:auth_user]['user_id']).to eq user_id
        end

        it "has set provider_count" do
          expect(controller.request.session[:auth_user][:provider_count]).to eq nil
        end

        describe 'sentry contexts' do
          before do
            allow(Raven).to receive(:user_context)
            allow(Raven).to receive(:tags_context)
          end

          it 'sets the id in the user context' do
            controller.authenticate

            expect(Raven).to have_received(:user_context).with(id: user_id)
          end

          it 'sets the DFE sign-in id in the tags context' do
            controller.authenticate

            expect(Raven).to have_received(:tags_context)
                               .with(sign_in_user_id: sign_in_user_id)
          end
        end
      end

      context 'user_id is blank' do
        let(:user_id) { 999 }

        before do
          allow(Session).to receive(:create)
                              .with(first_name: user_info[:first_name],
                                    last_name: user_info[:last_name])
                              .and_return(double(id: user_id))
          allow(Provider).to receive_message_chain(:where, :all)
                               .and_return(%w[one two])

          controller.request.session = {
            auth_user: {
              "info"    => user_info,
              'uid'     => sign_in_user_id
            }
          }

          controller.authenticate
        end

        it "has performed jwt encoding" do
          expect(JWT).to have_received(:encode)
        end

        it "has called session create" do
          expect(Session).to have_received(:create)
        end

        it "has set user_id" do
          expect(controller.request.session[:auth_user]['user_id'])
            .to eq user_id
        end

        it "has set provider_count" do
          expect(controller.request.session[:auth_user][:provider_count])
            .to eq 2
        end

        describe 'sentry contexts' do
          before do
            allow(Raven).to receive(:user_context)
            allow(Raven).to receive(:tags_context)
          end

          it 'sets the id in the user context' do
            controller.authenticate

            expect(Raven).to have_received(:user_context).with(id: user_id)
          end

          it 'sets the DFE sign-in id in the tags context' do
            controller.authenticate

            expect(Raven).to have_received(:tags_context)
                               .with(sign_in_user_id: sign_in_user_id)
          end
        end
      end
    end
  end
end
