class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end

Rails.application.config.middleware.use OmniAuth::Builder do
  dfe_sign_in_issuer_uri = URI(ENV["DFE_SIGN_IN_ISSUER"])
  dfe_sign_in_identifier = ENV["DFE_SIGN_IN_IDENTIFIER"]
  dfe_sign_in_secret     = ENV["DFE_SIGN_IN_SECRET"]
  base_url               = ENV["BASE_URL"]

  dfe_sign_in_issuer_url = "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.port

  provider :dfe,
           name: :dfe,
           discovery: true,
           response_type: :code,
           issuer: dfe_sign_in_issuer_url,
           client_signing_alg: :RS256,
           scope: %i[openid profile email],
           client_options: {
             port: dfe_sign_in_issuer_uri.port,
             scheme: dfe_sign_in_issuer_uri.scheme,
             host: dfe_sign_in_issuer_uri.host,
             identifier: dfe_sign_in_identifier,
             secret: dfe_sign_in_secret,
             redirect_uri: "#{base_url}/auth/dfe/callback",
             authorization_endpoint: "/auth",
             jwks_uri: "/certs",
             userinfo_endpoint: "/me"
           }
end
