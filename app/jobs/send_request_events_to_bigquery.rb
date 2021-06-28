class SendRequestEventsToBigquery < ApplicationJob
  def perform(request_event_json)
    return unless FeatureService.enabled?(:send_request_data_to_bigquery)

    bq = Google::Cloud::Bigquery.new
    dataset = bq.dataset(Settings.google.bigquery.dataset, skip_lookup: true)
    bq_table = dataset.table(Settings.google.bigquery.table_name, skip_lookup: true)
    bq_table.insert([request_event_json])
  end
end
