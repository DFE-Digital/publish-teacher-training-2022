if AuthenticationService.persona?
  class PersonasController < ActionController::Base
    layout "application"

    def index
      clear_current_sessions
    end

    def current_user
      session[:auth_user].presence
    end
    helper_method :current_user

  private

    def clear_current_sessions
      session[:auth_user]&.clear
    end
  end
end
