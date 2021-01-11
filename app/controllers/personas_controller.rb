if AuthenticationService.persona?
  class PersonasController < ActionController::Base
    layout "application"

    def index; end

    def current_user
      session[:auth_user].presence
    end
    helper_method :current_user
  end
end
