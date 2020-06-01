class ProviderSuggestion < Base
  def self.suggest(query)
    requestor.__send__(
      :request, :get, "/api/v2/providers/suggest?query=#{query}"
    )
  end

  def self.suggest_any(query)
    requestor.__send__(
      :request, :get, "/api/v2/providers/suggest_any?query=#{query}"
    )
  end
end
