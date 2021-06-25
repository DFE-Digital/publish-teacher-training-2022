class RequestEvent
  def initialize
    @event_hash = {
      environment: ENV["RAILS_ENV"],
      timestamp: Time.zone.now.iso8601,
    }
  end

  def as_json
    @event_hash.as_json
  end

  def with_request_details(request)
    @event_hash.merge!(
      request_uuid: request.uuid,
      request_path: request.path,
      request_method: request.method,
    )

    self
  end

  def with_user(user)
    @event_hash.merge!(
      user_id: user&.fetch("user_id", nil),
    )
    self
  end
end
