class Session < Base
  class << self
    def create_by_magic(magic_link_token:, email:)
      payload = { email: email }
      token = JWT.encode(
        payload,
        Settings.manage_backend.secret,
        Settings.manage_backend.algorithm,
      )
      RequestStore.store[:manage_courses_backend_token] = token
      api_url = "#{site}sessions/create_by_magic"

      begin
        response = connection.run(
          :patch,
          api_url,
          params: { magic_link_token: magic_link_token },
        )
      rescue JsonApiClient::Errors::NotAuthorized
        # Normally this is handled by the controller, but in this case, we've
        # failed to login, not failed to have the permissions to view a page.
        # This translates into no session created and we return nil to caller.
        return nil
      end

      unless response.success?
        raise "#{response.status} received: #{response.reason_phrase}"
      end

      User.parser.parse(User, response).first
    end
  end
end
