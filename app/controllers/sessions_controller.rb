class SessionsController < ApplicationController
  def new
    redirect_to "/auth/dfe"
  end

  def create
    session[:auth_user] = auth_hash

    add_token_to_connection

    begin
      user = Session.create(first_name: current_user_info[:first_name], last_name: current_user_info[:last_name])
      session[:auth_user][:user_id] = user.id

      redirect_to root_path
    rescue JsonApiClient::Errors::NotAuthorized
      redirect_to Settings.manage_ui.base_url
    end
  end

  def signout
    redirect_to "#{Settings.dfe_signin.issuer}/session/end?id_token_hint=#{current_user['credentials']['id_token']}&post_logout_redirect_uri=#{Settings.dfe_signin.base_url}/auth/dfe/signout"
  end

  def failure
    redirect_to "/401"
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
