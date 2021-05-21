class UsersController < ApplicationController
  skip_before_action :check_interrupt_redirects

  def accept_transition_info
    user.accept_transition_screen!
    session["auth_user"]["attributes"]["state"] = user.state
    redirect_to root_path
  end

  def accept_rollover
    # If we really want to make sure that an invididual user has
    # accepted the screen, we could add a user id in here if there
    # are multuple accounts using the same machine?
    #
    # Users will however, have to endure the great hardship of accepting
    # this for every different browser they use during the rollover period
    cookies[:accepted_rollover] = {
      value: true,
      expires: 6.months.from_now,
    }
    redirect_to root_path
  end

  def accept_rollover_recruitment
    cookies[:accepted_rollover_recruitment] = {
      value: true,
      expires: 6.months.from_now,
    }
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
