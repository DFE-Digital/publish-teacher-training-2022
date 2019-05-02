class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: :not_found
  rescue_from JsonApiClient::Errors::NotAuthorized, with: :render_manage_ui
  rescue_from JsonApiClient::Errors::AccessDenied, with: :render_manage_ui

  before_action :authenticate

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found }
      format.json { render json: { error: 'Resource not found' }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def render_manage_ui
    redirect_to Settings.manage_ui.base_url
  end

  helper_method :current_user

  def current_user
    @current_user ||= session[:auth_user] if session[:auth_user]
  end

  def authenticate
    if current_user
      add_token_to_connection
      set_has_multiple_providers

      set_user_session if current_user['user_id'].blank?
    else
      session[:redirect_back_to] = request.path
      redirect_to '/signin'
    end
  end

  def current_user_info
    current_user['info']
  end

  def current_user_dfe_signin_id
    current_user['uid']
  end

  def set_has_multiple_providers
    @has_multiple_providers = has_multiple_providers?
  end

  def has_multiple_providers?
    provider_count = session.to_hash.dig("auth_user", "provider_count")
    provider_count.nil? || provider_count > 1
  end

private

  def set_user_session
    user = Session.create(first_name: current_user_info[:first_name],
                          last_name: current_user_info[:last_name])
    session[:auth_user]['user_id'] = user.id

    add_provider_count_cookie

    user
  end

  def add_provider_count_cookie
    begin
      session[:auth_user][:provider_count] = Provider.all.size
    rescue StandardError => e
      logger.error "Error setting the provider_count cookie: #{e.class.name}, #{e.message}"
    end
  end

  def add_token_to_connection
    payload = {
      email:           current_user_info['email'].to_s,
      sign_in_user_id: current_user_dfe_signin_id
    }
    token = JWT.encode(payload,
                       Settings.authentication.secret,
                       Settings.authentication.algorithm)

    Thread.current[:manage_courses_backend_token] = token
  end
end
