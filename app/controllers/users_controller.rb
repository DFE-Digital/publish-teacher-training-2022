class UsersController < ApplicationController
  skip_before_action :check_interrupt_redirects

  def accept_transition_info
    user.accept_transition_screen!
    session["auth_user"]["attributes"]["state"] = user.state
    redirect_to root_path
  end

  def accept_rollover
    user.accept_rollover_screen!
    session["auth_user"]["attributes"]["state"] = user.state
    redirect_to root_path
  end

  def accept_notifications_info
    user.accept_notifications_screen!
    session["auth_user"]["attributes"]["state"] = user.state
    redirect_to root_path
  end

  def accept_terms
    if params.require(:user)[:terms_accepted] == "1"
      result = User.member(current_user["user_id"]).accept_terms
      session["auth_user"]["attributes"]["accept_terms_date_utc"] = result.first.accept_terms_date_utc
      redirect_to root_path
    else
      @errors = { user_terms_accepted: ["You must accept the terms and conditions to continue"] }
      render template: "pages/accept_terms"
    end
  end

private

  def user
    @user ||= User.find(current_user["user_id"]).first
  end
end
