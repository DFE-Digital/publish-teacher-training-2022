class SessionsController < ApplicationController
  skip_before_action :request_login
  skip_before_action :check_interrupt_redirects
  skip_before_action :verify_authenticity_token, if: proc { Settings.developer_auth }

  def create
    redirect_to sign_in_path and return unless FeatureService.enabled? :dfe_signin

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

    Raven.tags_context(sign_in_user_id: current_user.fetch("uid"))
    add_token_to_connection
    set_user_session

    # current_user['user_id'] won't be set until set_user_session is run
    Raven.user_context(id: current_user["user_id"])
    logger.debug { "User session create " + log_safe_current_user.to_s }

    redirect_to root_path
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

    redirect_to root_path
  end

  def send_magic_link
    FeatureService.require(:signin_by_email)

    User.generate_and_send_magic_link(params.require(:user).require(:email))

    redirect_to magic_link_sent_path
  end

  def magic_link_sent; end

  def signout
    if current_user.present?
      case session[:auth_user]["provider"]
      when "developer"
        reset_session
        redirect_to "/personas"
      else
        if magic_link_enabled?
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
end
