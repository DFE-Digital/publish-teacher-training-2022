class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: :not_found
  rescue_from JsonApiClient::Errors::NotAuthorized, with: :render_unauthorized
  rescue_from JsonApiClient::Errors::AccessDenied, with: :handle_access_denied

  include Pagy::Backend

  before_action :authenticate
  before_action :store_request_id
  before_action :request_login

  def not_found
    respond_with_error(template: "errors/not_found", status: :not_found, error_text: "Resource not found")
  end

  def render_unauthorized
    # Backend responds with 401 if there is no matching record in the users table.
    # Show the "We don't know which organisation you're part of" page to give users a route
    # to getting access
    render "providers/no_providers", status: :unauthorized
  end

  def handle_access_denied(exception)
    if user_has_not_accepted_terms(exception.env.body)
      redirect_to accept_terms_path
    else
      respond_with_error(template: "errors/forbidden", status: :forbidden, error_text: "Forbidden request")
    end
  end

  helper_method :current_user

  def current_user
    if is_authenticated?
      session[:auth_user]
    elsif development_mode_auth?
      user = authenticate_with_http_basic do |email, pass|
        authorise_development_mode?(email, pass)
      end
      if user.present?
        setup_development_mode_session(
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
        )
      end
    end
  end

  def is_authenticated?
    session[:auth_user].present?
  end

  def user_is_admin?
    current_user["admin"]
  end

  def user_state
    current_user["state"]
  end

  def log_safe_current_user(reload: false)
    if @log_safe_current_user.nil? || reload
      @log_safe_current_user = current_user.dup
      email = @log_safe_current_user["info"]&.fetch("email", "")
      @log_safe_current_user.delete("info")
      @log_safe_current_user["email_md5"] = Digest::MD5.hexdigest(email)
    end
    @log_safe_current_user
  end

  def development_mode_auth?
    !Rails.env.production? && Settings.key?(:authorised_users)
  end

  def authenticate
    if current_user.present?
      logger.info { "Authenticated user session found " + log_safe_current_user.to_s }

      assign_sentry_contexts
      assign_logstash_contexts
      add_token_to_connection
      set_has_multiple_providers

      if current_user["user_id"].blank?
        set_user_session
        Raven.user_context(id: current_user["user_id"])
        logger.debug { "User session set. " + log_safe_current_user(reload: true).to_s }
      end
    end
  end

  def request_login
    return if current_user.present?

    if development_mode_auth?
      logger.info("Doing development mode authentication")
      request_http_basic_authentication("Development Mode")
    else
      logger.info("Authenticated user session not found " + {
        redirect_back_to: request.path,
      }.to_s)
      session[:redirect_back_to] = request.path
      redirect_to "/signin"
    end
  end

  def current_user_info
    current_user["info"]
  end

  def current_user_dfe_signin_id
    current_user["uid"]
  end

  def set_has_multiple_providers
    @has_multiple_providers = has_multiple_providers?
  end

  def has_multiple_providers?
    provider_count = session.to_hash.dig("auth_user", "provider_count")
    provider_count.nil? || provider_count > 1
  end

private

  def authorise_development_mode?(email, password)
    _, user = Settings.authorised_users.find do |_index, user|
      user.email == email && user.password == password
    end

    user
  end

  def setup_development_mode_session(email:, first_name:, last_name:)
    session[:auth_user] = HashWithIndifferentAccess.new(
      uid: SecureRandom.uuid,
      info: HashWithIndifferentAccess.new(
        email: email,
        first_name: first_name,
        last_name: last_name,
      ),
      credentials: HashWithIndifferentAccess.new(
        id_token: "id_token",
      ),
    )
  end

  def user_has_not_accepted_terms(response_body)
    return false unless response_body.is_a?(Hash)

    response_body.key?("meta") &&
      response_body["meta"]["error_type"] == "user_not_accepted_terms_and_conditions"
  end

  def respond_with_error(template:, status:, error_text:)
    respond_to do |format|
      format.html { render template, status: status }
      format.json { render json: { error: error_text }, status: status }
      format.all { render status: status, body: nil }
    end
  end

  def set_user_session
    logger.debug do
      "Creating new session for user " + {
        email_md5: log_safe_current_user["email_md5"],
        signin_id: current_user_dfe_signin_id,
      }.to_s
    end

    # TODO: we should return a session object here with a 'user' attached to id.
    user = Session.create(
      first_name: current_user_info[:first_name],
      last_name: current_user_info[:last_name],
    )
    set_session_info_for_user(user)

    user
  end

  def set_session_info_for_user(user)
    session[:auth_user]["user_id"] = user.id
    session[:auth_user]["state"] = user.state
    session[:auth_user]["admin"] = user.admin

    add_provider_count_cookie
  end

  def add_provider_count_cookie
    session[:auth_user][:provider_count] =
      Provider.where(recruitment_cycle_year: Settings.current_cycle).all.size
  rescue StandardError => e
    logger.error "Error setting the provider_count cookie: #{e.class.name}, #{e.message}"
  end

  def add_token_to_connection
    payload = {
      email: current_user_info["email"].to_s,
      first_name: current_user_info["first_name"].to_s,
      last_name: current_user_info["last_name"].to_s,
      sign_in_user_id: current_user_dfe_signin_id,
    }

    # Attempting to debug blanking of name information
    if payload[:first_name].blank?
      logger.warn "first_name missing for sign in user id: #{payload[:sign_in_user_id]}"
    end

    if payload[:last_name].blank?
      logger.warn "last_name missing for sign in user id: #{payload[:sign_in_user_id]}"
    end

    if payload[:email].blank?
      logger.warn "email missing for sign in user id: #{payload[:sign_in_user_id]}"
    end
    # end of debugging

    token = JWT.encode(
      payload,
      Settings.manage_backend.secret,
      Settings.manage_backend.algorithm,
    )

    RequestStore.store[:manage_courses_backend_token] = token
  end

  def assign_sentry_contexts
    Raven.user_context(id: current_user["user_id"])
    Raven.tags_context(sign_in_user_id: current_user.fetch("uid"))
    Raven.extra_context(request_id: request.uuid)
  end

  def assign_logstash_contexts
    Thread.current[:logstash] ||= {}
    Thread.current[:logstash][:user_id] = current_user["user_id"]
    Thread.current[:logstash][:sign_in_user_id] = current_user["uid"]
  end

  def append_info_to_payload(payload)
    super

    if current_user.present?
      payload[:user] = {
        id: current_user["user_id"],
        sign_in_user_id: current_user.fetch("uid"),
      }
      payload[:request_id] = request.uuid
    end
  end

  def store_request_id
    RequestStore.store[:request_id] = request.uuid
  end
end
