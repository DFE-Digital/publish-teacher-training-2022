class UsersController < ApplicationController
  def accept_transition_info
    user = User.new(id: current_user["user_id"])
    user.accept_transition_screen
    redirect_to providers_path
  end
end
