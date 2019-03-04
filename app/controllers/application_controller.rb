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
    if current_user
      set_connection
    else
      redirect_to '/signin'
    end
  end

  def current_user_info
    current_user['info']
  end

private

  def set_connection
    if Settings.authentication.algorithm == 'plain-text'
      # This method can be used in development mode to simplify querying
      # the API with curl. It should allow us to do:
      #
      #    curl -H 'Authorization: Bearer user@education.gov.uk' http://localhost:3001/api/v2/providers
      token = current_user_info['email'].to_s
    else
      payload = { email: current_user_info['email'].to_s }
      token = JWT.encode(payload.to_json,
                          Settings.authentication.secret,
                          Settings.authentication.algorithm)
    end

    Base.connection do |connection|
      connection.use FaradayMiddleware::OAuth2, token, token_type: :bearer
    end
  end
end
