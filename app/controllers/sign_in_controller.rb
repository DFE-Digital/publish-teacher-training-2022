class SignInController < ApplicationController
  skip_before_action :request_login
  skip_before_action :check_interrupt_redirects

  def index
    render "index"
  end
end
