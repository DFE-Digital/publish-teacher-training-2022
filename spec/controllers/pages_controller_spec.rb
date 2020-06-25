require "rails_helper"

describe PagesController, type: :controller do
  context "user has state 'transitioned'" do
    let(:current_user) do
      {
        user_id: 1,
        uid: SecureRandom.uuid,
        info: {
          email: "dave@example.com",
          state: "transitioned",
        },
      }.with_indifferent_access
    end

    let(:user) { build(:user, :transitioned, id: 1) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
                                                        .and_return(current_user)
      stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)
    end

    scenario "user visits '/transition-info'" do
      get :transition_info
      expect(response).to redirect_to(root_path)
    end
  end

  context "user has state 'rolled_over'" do
    let(:current_user) do
      {
        user_id: 1,
        uid: SecureRandom.uuid,
        info: {
          email: "dave@example.com",
          state: "transitioned",
        },
      }.with_indifferent_access
    end

    let(:user) { build(:user, :transitioned, id: 1) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
                                                        .and_return(current_user)
      stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)
    end

    scenario "user visits '/rollover'" do
      get :rollover
      expect(response).to redirect_to(root_path)
    end
  end

  context "user has state 'rolled_over', is associated with an accredited body and does not have notifications configured" do
    let(:current_user) do
      {
        user_id: 1,
        uid: SecureRandom.uuid,
        info: {
          email: "dave@example.com",
          state: "transitioned",
          associated_with_accredited_body: true,
          notifications_configured: false,
        },
      }.with_indifferent_access
    end

    let(:user) do
      build(
        :user,
        :rolled_over,
        id: 1,
        associated_with_accredited_body: true,
        notifications_configured: false,
      )
    end

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
                                                        .and_return(current_user)
      stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)
    end

    scenario "user visits '/rollover'" do
      get :rollover
      expect(response).to redirect_to(notifications_info_path)
    end
  end

  context "user has state 'notifications_configured'" do
    let(:current_user) do
      {
        user_id: 1,
        uid: SecureRandom.uuid,
        info: {
          email: "dave@example.com",
          state: "transitioned",
          associated_with_accredited_body: true,
          notifications_configured: false,
        },
      }.with_indifferent_access
    end

    let(:user) do
      build(
        :user,
        :notifications_configured,
        id: 1,
      )
    end

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
                                                        .and_return(current_user)
      stub_api_v2_request("/users/#{user.id}", user.to_jsonapi)
    end

    scenario "user visits '/notification-info'" do
      get :notifications_info
      expect(response).to redirect_to(root_path)
    end
  end
end
