class HeartbeatController < ActionController::API
  def ping
    render body: "PONG"
  end

  def sha
    render json: { sha: commit_sha }
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
    response = Faraday.get("#{Settings.manage_backend.base_url}/healthcheck")
    response.success?
  rescue StandardError
    false
  end

  def commit_sha_path
    Rails.root.join(Settings.commit_sha_file)
  end

  def commit_sha
    File.read(commit_sha_path).strip
  end
end
