class UsersController < ApplicationController
  skip_before_action :check_interrupt_redirects

  def accept_transition_info
    user.accept_transition_screen!
    session["auth_user"]["attributes"]["state"] = user.state
    redirect_to root_path
  end

  def accept_rollover
    InterruptPageAcknowledgement.create(
      user_id: user.id,
      recruitment_cycle_year: Settings.current_cycle.next,
      page: "rollover"
    )
    session["auth_user"]["accepted_rollover"] = true
    redirect_to root_path
  end

  def accept_rollover_recruitment
    InterruptPageAcknowledgement.create(
      user_id: user.id,
      recruitment_cycle_year: Settings.current_cycle.next,
      page: "rollover_recruitment"
    )
    session["auth_user"]["accepted_rollover_recruitment"] = true
    redirect_to root_path
  end

  # This terms screen is the only existing interrupt screen that doesn't use the state machine
  # If we want to have data around how many users have accepted the rollover screens we could
  # add timestamps like this, but it seems less important.
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
