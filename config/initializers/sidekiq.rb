redis_credentials = ENV["REDIS_URL"]
if ENV.key?("VCAP_SERVICES")
  service_config = JSON.parse(ENV["VCAP_SERVICES"])
  redis_config = service_config["redis"].first
  vcap_redis_credentials = redis_config["credentials"]
  redis_credentials = vcap_redis_credentials["uri"]
end

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_credentials,
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_credentials,
  }
end
