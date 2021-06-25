module EmitRequestEvents
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    after_action :trigger_request_event
  end

  def trigger_request_event
    if FeatureService.enabled?(:send_request_data_to_bigquery)
      request_event = RequestEvent.new
        .with_request_details(request)
        .with_user(current_user)

      SendRequestEventsToBigquery.perform_later(request_event.as_json)
    end
  end
end
