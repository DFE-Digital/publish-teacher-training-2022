class SessionsController < ApplicationController
  skip_before_action :request_login

  def new
    if FeatureService.enabled? :signin_intercept
      render
    else
      redirect_to "/auth/dfe"
    end
  end

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
    )

    Raven.tags_context(sign_in_user_id: current_user.fetch("uid"))
    add_token_to_connection
    set_user_session

    # current_user['user_id'] won't be set until set_user_session is run
    Raven.user_context(id: current_user["user_id"])
    logger.debug { "User session create " + log_safe_current_user.to_s }

    user = user_from_session
    redirect_to_correct_page(user)
  end

  def create_by_magic
    FeatureService.require(:signin_by_email)

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
      Raven.user_context(id: current_user["user_id"])
      logger.debug { "User session create_by_magic " + log_safe_current_user.to_s }
    end

    user = user_from_session
    redirect_to_correct_page(user)
  end

  def send_magic_link
    FeatureService.require(:signin_by_email)

    User.generate_and_send_magic_link(params.require(:user).require(:email))

    redirect_to magic_link_sent_path
  end

  def magic_link_sent; end

  def signout
    if current_user.present?
      if development_mode_auth?
        # Disappointingly, with HTTP basic auth it's trick to really log
        # someone out, since the browser just holds onto the user's username /
        # password and re-submits it until their session ends. So they'll just
        # create a new session after this "logout".
        reset_session
        redirect_to root_path
      else
        uri = URI("#{Settings.dfe_signin.issuer}/session/end")
        uri.query = {
          id_token_hint: current_user["credentials"]["id_token"],
          post_logout_redirect_uri: "#{Settings.dfe_signin.base_url}/auth/dfe/signout",
        }.to_query
        redirect_to uri.to_s
      end
    else
      redirect_to root_path
    end
  end

  def failure
    render "errors/unauthorized", status: :unauthorized
  end

  def destroy
    session.destroy
    redirect_to root_path
  end

private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def redirect_to_correct_page(user)
    if user&.accept_terms_date_utc.nil?
      redirect_to accept_terms_path
    elsif user.next_state
      redirect_to redirect_path[user.next_state]
    else
      redirect_to session[:redirect_back_to] || root_path
    end
  end

  def redirect_path
    {
      rolled_over: rollover_path,
      accepted_rollover_2021: rollover_path,
      notifications_configured: notifications_info_path,
      transitioned: transition_info_path,
    }
  end
end
