class HeartbeatController < ActionController::API
  include HTTParty

  def ping
    render body: "PONG"
  end

  def healthcheck
    checks = {
      teacher_training_api: api_alive?,
    }

    status = checks.values.all? ? :ok : :bad_gateway

    render status: status, json: {
      checks: checks,
    }
  end

private

  def api_alive?
    response = HeartbeatController.get("#{Settings.manage_backend.base_url}/healthcheck")
    response.success?
  rescue StandardError
    false
  end
end
