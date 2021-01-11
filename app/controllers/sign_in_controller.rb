class SignInController < ApplicationController
  skip_before_action :request_login
  skip_before_action :check_interrupt_redirects

  def index
    if AuthenticationService.magic?
      render "dfe_sign_in_is_down"
    else
      render "index"
    end
  end
end
