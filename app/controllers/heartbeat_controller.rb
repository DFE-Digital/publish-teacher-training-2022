class HeartbeatController < ActionController::API
  def ping
    render body: "PONG"
  end

  def sha
    render json: { sha: ENV["COMMIT_SHA"] }
  end

  def healthcheck
    checks = {
      teacher_training_api: api_alive?,
    }

    status = checks.values.all? ? :ok : :service_unavailable

    render status: status,
           json: {
             checks: checks,
           }
  end

private

  def api_alive?
    response = Faraday.get("#{Settings.teacher_training_api.base_url}/healthcheck")
    response.success?
  rescue StandardError
    false
  end
end
