module MagicLink
  class GenerateAndSendService
    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(email:, site:)
      @email = email
      @site = site
    end

    def call
      payload = {
        email: @email,
      }
      token = JWT.encode(
        payload,
        Settings.manage_backend.secret,
        Settings.manage_backend.algorithm,
      )

      post_url = "#{@site}users/generate_and_send_magic_link"
      response = Faraday.patch(
        post_url,
        {},
        { "Authorization" => "Bearer #{token}",
          "X-Request-Id" => RequestStore.store[:request_id] },
      )

      unless response.success?
        raise "#{response.status} received: #{response.reason_phrase}"
      end
    end
  end
end
