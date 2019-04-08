# JSON API client uses the title as the error message if it's available, but
# for our use case, the `detail` part of the message is more useful. The
# recommended method to work around this is by monkey patching:
# https://github.com/JsonApiClient/json_api_client/pull/272#issuecomment-392263936
module JsonApiClient
  class ErrorCollector
    class Error
      def error_msg
        detail || title || "invalid"
      end
    end
  end
end
