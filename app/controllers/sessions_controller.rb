class SessionsController < ApplicationController
  def create
    session[:auth_user] = auth_hash
    redirect_to root_path
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
