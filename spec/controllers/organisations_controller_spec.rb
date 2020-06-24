require "rails_helper"

describe OrganisationsController, type: :controller do
  let(:current_user) do
    {
      user_id: 1,
      uid: SecureRandom.uuid,
      info: {
        email: "dave@example.com",
      },
    }.with_indifferent_access
  end

  let(:user) { build(:user) }
  let(:organisation_scope) { double }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user)
      .and_return(current_user)
    allow(Organisation).to receive_message_chain("order.includes.page").and_return(double(meta: { count: 0 }))
  end

  context "requested page overflows" do
    it "returns a 404" do
      expect { get :index, params: { page: 2 } }.to raise_error(ActionController::RoutingError)
    end
  end
end
