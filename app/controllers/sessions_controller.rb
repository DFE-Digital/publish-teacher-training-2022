class SessionsController < ApplicationController
  def new
    redirect_to "/auth/dfe"
  end

  def create
    session[:auth_user] = auth_hash
    redirect_to root_path
  end

  def signout
    redirect_to "#{ENV['DFE_SIGN_IN_ISSUER']}/session/end?id_token_hint=#{current_user['credentials']['id_token']}&post_logout_redirect_uri=#{ENV['BASE_URL']}/auth/dfe/signout"
  end

  def destroy
    session.destroy
    redirect_to root_path
  end

private

  def auth_hash
    request.env["omniauth.auth"]
  end
end
