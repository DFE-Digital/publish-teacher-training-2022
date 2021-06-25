class RequestEvent
  def initialize
    @event_hash = {
      environment: ENV["RAILS_ENV"],
      occurred_at: Time.zone.now.iso8601,
      event_type: "web_request",
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
      request_user_agent: request.user_agent,
      request_query: query_to_kv_pairs(request.query_string),
      request_referer: request.referer,
    )

    self
  end

  def with_response_details(response)
    @event_hash.merge!(
      response_content_type: response.content_type,
      response_status: response.status,
    )

    self
  end

  def with_user(user)
    @event_hash.merge!(
      user_id: user&.fetch("user_id", nil),
    )
    self
  end

private

  def query_to_kv_pairs(query_string)
    vars = Rack::Utils.parse_query(query_string)
    vars.map { |k, v| { "key" => k, "value" => v } }
  end
end
