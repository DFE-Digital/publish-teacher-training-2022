class Base < JsonApiClient::Resource
  # This connection class grabs the bearer token from the thread key-value
  # store and adds it to our connection. This token was saved there for us when
  # the user was first authenticated.
  class MCBConnection < JsonApiClient::Connection
    def run(request_method, path, params: nil, headers: {}, body: nil)
      authorization = "Bearer #{Thread.current.fetch(:manage_courses_backend_token)}"
      super(
        request_method,
        path,
        params: params,
        headers: headers.update('Authorization' => authorization),
        body: body
      )
    end
  end

  include Draper::Decoratable

  self.site = "#{Settings.manage_backend.base_url}/api/v2/"
  self.connection_class = MCBConnection
end
