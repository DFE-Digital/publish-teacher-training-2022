class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: :not_found

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found }
      format.json { render json: { error: 'Resource not found' }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  helper_method :current_user

  def current_user
    @current_user ||= session[:auth_user] if session[:auth_user]
  end

  def authenticate
    redirect_to '/signin' unless current_user
  end
end
