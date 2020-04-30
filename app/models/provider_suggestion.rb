class ProviderSuggestion < Base
  def self.suggest(query)
    requestor.__send__(
      :request, :get, "/api/v2/providers/suggest?query=#{query}"
    )
  end
end
