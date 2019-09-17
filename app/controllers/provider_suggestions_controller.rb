class ProviderSuggestionsController < ApplicationController
  skip_before_action :authenticate

  def suggest
    suggestions = ProviderSuggestion.suggest(params[:query])
      .map { |provider| { code: provider.provider_code, name: provider.provider_name } }
    render json: suggestions
  end
end
