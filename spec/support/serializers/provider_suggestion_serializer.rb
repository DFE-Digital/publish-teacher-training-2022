class ProviderSuggestionSerializer < JSONAPI::Serializable::Resource
  type "provider"

  attributes(*FactoryBot.attributes_for("provider_suggestion").keys)
end
