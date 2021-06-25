class SendRequestEventsToBigquery < ApplicationJob
  TABLE_NAME = "events".freeze

  def perform(request_event_json)
    bq = Google::Cloud::Bigquery.new
    dataset = bq.dataset(Settings.google.bigquery.dataset, skip_lookup: true)
    bq_table = dataset.table(TABLE_NAME, skip_lookup: true)
    bq_table.insert([request_event_json])
  end
end
