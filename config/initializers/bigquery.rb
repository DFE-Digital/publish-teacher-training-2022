require 'google/cloud/bigquery'

BIG_QUERY_API_JSON_KEY = Settings.google.bigquery.api_json_key

if BIG_QUERY_API_JSON_KEY.present?
  Google::Cloud::Bigquery.configure do |config|
    config.project_id  = Settings.google.bigquery.project_id
    config.credentials = JSON.parse(BIG_QUERY_API_JSON_KEY)
  end

  Google::Cloud::Bigquery.new
end
