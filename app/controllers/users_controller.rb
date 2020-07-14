class UsersController < ApplicationController
  def accept_transition_info
    UpdateUserService.call(user, "accept_transition_screen!")
    redirect_to FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") ? rollover_path : providers_path
  end

  def accept_rollover
    UpdateUserService.call(user, "accept_rollover_screen!")
    redirect_to providers_path
  end

  def accept_notifications_info
    UpdateUserService.call(user, "accept_notifications_screen!")
    redirect_to providers_path
  end

  def accept_terms
    if params.require(:user)[:terms_accepted] == "1"
      result = User.member(current_user["user_id"]).accept_terms
      session["auth_user"]["attributes"]["accept_terms_date_utc"] = result.first.accept_terms_date_utc
      redirect_to page_after_accept_terms
    else
      @errors = { user_terms_accepted: ["You must accept the terms and conditions to continue"] }
      render template: "pages/accept_terms"
    end
  end

private

  def user
    @user = User.find(current_user["user_id"]).first
  end

  def page_after_accept_terms
    case user_state
    when "new"
      transition_info_path
    when "transitioned"
      rollover_path
    else
      session[:redirect_back_to] || root_path
    end
  end
end
