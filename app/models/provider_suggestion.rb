class ProviderSuggestion < Base
  def self.suggest(query)
    self.requestor.__send__(
      :request, :get, "/api/v2/providers/suggest?query=#{query}"
    )
  end
end
