module OmniAuth
  module Strategies
    class OpenIDConnect
      def callback_phase
        error = request.params['error_reason'] || request.params['error']
        if error
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        elsif request.params['state'].to_s.empty? || request.params['state'] != stored_state
          # Monkey patch: Ensure a basic 401 rack response with no body or header isn't served
          # return Rack::Response.new(['401 Unauthorized'], 401).finish
          return redirect('/auth/failure')
        elsif !request.params['code']
          return fail!(:missing_code, OmniAuth::OpenIDConnect::MissingCodeError.new(request.params['error']))
        else
          options.issuer = issuer if options.issuer.blank?
          discover! if options.discovery
          client.redirect_uri = redirect_uri
          client.authorization_code = authorization_code
          access_token
          super
        end
      rescue CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end
    end
  end
end

class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end

if ENV['DFE_SIGN_IN_ISSUER'].present?
  dfe_sign_in_issuer_uri = URI.parse(ENV['DFE_SIGN_IN_ISSUER'])
  options = {
    name: :dfe,
    discovery: true,
    response_type: :code,
    client_signing_alg: :RS256,
    scope: %i[openid profile email offline_access],
    client_options: {
      port: dfe_sign_in_issuer_uri.port,
      scheme: dfe_sign_in_issuer_uri.scheme,
      host: dfe_sign_in_issuer_uri.host,
      identifier: ENV['DFE_SIGN_IN_IDENTIFIER'],
      secret: ENV['DFE_SIGN_IN_SECRET'],
      redirect_uri: "#{ENV['BASE_URL']}/auth/dfe/callback",
      authorization_endpoint: '/auth',
      jwks_uri: '/certs',
      userinfo_endpoint: '/me'
    }
  }

  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options

  class DfeSignIn
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.path == '/auth/failure'
        response = Rack::Response.new
        response.redirect('/401')
        response.finish
      elsif request.path == '/auth/dfe/callback' && request.params.empty? && !OmniAuth.config.test_mode
        response = Rack::Response.new
        response.redirect('/dfe/sessions/new')
        response.finish
      else
        @app.call(env)
      end
    end
  end

  Rails.application.config.middleware.insert_before OmniAuth::Strategies::OpenIDConnect, DfeSignIn
end
