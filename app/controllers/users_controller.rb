class UsersController < ApplicationController
  def accept_transition_info
    accept_screen("accept_transition_screen", rollover_path)
  end

  def accept_rollover
    accept_screen("accept_rollover_screen", providers_path)
  end

  def accept_terms
    if params.require(:user)[:terms_accepted] == "1"
      accept_screen("accept_terms", page_after_accept_terms)
    else
      @errors = { user_terms_accepted: ["You must accept the terms and conditions to continue"] }
      render template: "pages/accept_terms"
    end
  end

private

  def accept_screen(method, path)
    User.member(current_user["user_id"]).send(method)
    redirect_to path
  rescue JsonApiClient::Errors::ClientError, JsonApiClient::Errors::ServerError => e
    e.env.body.delete("traces")
    Raven.extra_context(e.env)

    if e.is_a? JsonApiClient::Errors::ClientError
      Raven.capture_exception(e)
      redirect_to path
    else
      raise e
    end
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
