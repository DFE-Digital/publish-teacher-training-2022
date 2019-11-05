class SessionsController < ApplicationController
  skip_before_action :authenticate

  def new
    redirect_to "/auth/dfe"
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
    user = set_user_session

    # current_user['user_id'] won't be set until set_user_session is run
    Raven.user_context(id: current_user["user_id"])
    logger.debug { "User session create " + log_safe_current_user.to_s }

    redirect_to_correct_page(user)
  end

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
    if user.accept_terms_date_utc.nil?
      redirect_to accept_terms_path
    elsif user.state == "new"
      redirect_to transition_info_path
    elsif Settings.rollover && user.state == "transitioned"
      redirect_to rollover_path
    else
      redirect_to session[:redirect_back_to] || root_path
    end
  end
end
