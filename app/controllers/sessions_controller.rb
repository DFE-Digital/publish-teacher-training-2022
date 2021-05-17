class SessionsController < ApplicationController
  skip_before_action :request_login
  skip_before_action :check_interrupt_redirects
  skip_before_action :verify_authenticity_token, if: proc { AuthenticationService.persona? }

  def create
    session[:auth_user] = HashWithIndifferentAccess.new(
      "uid" => auth_hash.dig("uid"),
      "info" => HashWithIndifferentAccess.new(
        email: auth_hash.dig("info", "email"),
        first_name: auth_hash.dig("info", "first_name"),
        last_name: auth_hash.dig("info", "last_name"),
      ),
      "credentials" => HashWithIndifferentAccess.new(
        "id_token" => auth_hash.dig("credentials", :id_token),
      ),
      "provider" => auth_hash.dig("provider"),
    )

    Sentry.set_tags(sign_in_user_id: current_user.fetch("uid"))
    add_token_to_connection
    set_user_session

    # current_user['user_id'] won't be set until set_user_session is run
    Sentry.set_user(id: current_user["user_id"])
    logger.debug { "User session create " + log_safe_current_user.to_s }

    redirect_to root_path
  end

  def create_by_magic
    user_session = Session.create_by_magic(
      magic_link_token: params.require(:token),
      email: params.require(:email),
    )

    if user_session
      session[:auth_user] = HashWithIndifferentAccess.new(
        "uid" => nil,
        "info" => HashWithIndifferentAccess.new(
          email: user_session.email,
          first_name: user_session.first_name,
          last_name: user_session.last_name,
        ),
        "credentials" => HashWithIndifferentAccess.new(
          "id_token" => nil,
        ),
      )
      set_session_info_for_user(user_session)
      Sentry.set_user(id: current_user["user_id"])
      logger.debug { "User session create_by_magic " + log_safe_current_user.to_s }
    end

    redirect_to root_path
  end

  def send_magic_link
    User.generate_and_send_magic_link(params.require(:user).require(:email))

    redirect_to magic_link_sent_path
  end

  def magic_link_sent; end

  def signout
    url = signout_redirect_url
    reset_session

    redirect_to url
  end

  def failure
    render "errors/unauthorized", status: :unauthorized
  end

  def destroy
    session.destroy
    redirect_to root_path
  end

private

  def signout_redirect_url
    if AuthenticationService.magic_link?
      root_path
    elsif AuthenticationService.persona?
      "/personas"
    elsif current_user.present?
      uri = URI("#{Settings.dfe_signin.issuer}/session/end")
      uri.query = {
        id_token_hint: current_user["credentials"]["id_token"],
        post_logout_redirect_uri: "#{Settings.dfe_signin.base_url}/auth/dfe/signout",
      }.to_query
      uri.to_s
    else
      root_path
    end
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
