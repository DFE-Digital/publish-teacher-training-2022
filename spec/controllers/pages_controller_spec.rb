require "rails_helper"

describe PagesController, type: :controller do
  let(:current_user) do
    {
      user_id: 1,
      uid: SecureRandom.uuid,
      info: {
        email: "dave@example.com",
      },
    }.with_indifferent_access
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  scenario "user visits '/transition-info'" do
    get :transition_info
    expect(response).to be_successful
  end

  scenario "user visits '/rollover'" do
    get :rollover
    expect(response).to be_successful
  end

  scenario "user visits '/notification-info'" do
    get :notifications_info
    expect(response).to be_successful
  end
end
