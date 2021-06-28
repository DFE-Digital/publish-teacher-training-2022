require "google/cloud/bigquery"

if FeatureService.enabled?(:send_request_data_to_bigquery)
  Google::Cloud::Bigquery.configure do |config|
    config.project_id  = Settings.google.bigquery.project_id
    config.credentials = JSON.parse(ENV["BIG_QUERY_API_JSON_KEY"])
  end

  Google::Cloud::Bigquery.new
end
