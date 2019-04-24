class UsersController < ApplicationController
  before_action :authenticate

  def accept_transition_info
    User.member(current_user['user_id']).accept_transition_screen
    redirect_to providers_path
  end
end
