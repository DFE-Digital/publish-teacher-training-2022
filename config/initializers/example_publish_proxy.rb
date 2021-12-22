class ExamplePublishProxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)

    path_matchers = [
      %r{^/organisations/\w+/\d{4}/details},
      %r{^/organisations/\w+/\d{4}/about},
      %r{^/organisations/\w+/\d{4}/contact},
      %r{^/publish/organisations/\w+/\d{4}/details},
      %r{^/publish/organisations/\w+/\d{4}/about},
      %r{^/publish/organisations/\w+/\d{4}/contact},
    ]
    matched = path_matchers.any? { |m| request.path =~ m }

    if matched
      env["HTTP_HOST"] = request.host_with_port

      env["PATH_INFO"] = if request.fullpath.include?("/publish")
                           request.fullpath
                         else
                           "/publish#{request.fullpath}"
                         end

      # Prevent Keep-Alive from causing a delay of several seconds in each request
      env["HTTP_CONNECTION"] = "close"

      # Don't send your sites cookies to target service, unless it is a trusted internal service that can parse all your cookies
      # env["HTTP_COOKIE"] = ""
      super(env)
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.use ExamplePublishProxy, backend: "http://www.ttapi.test:3001", streaming: false
