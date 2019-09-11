class UsersController < ApplicationController
  def accept_transition_info
    accept_screen('accept_transition_screen', Settings.rollover ? rollover_path : providers_path)
  end

  def accept_rollover
    accept_screen('accept_rollover_screen', providers_path)
  end

  def accept_terms
    accept_screen('accept_terms', providers_path)
  end

private

  def accept_screen(method, path)
    User.member(current_user['user_id']).send(method)
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
end
