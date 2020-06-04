class ProviderSuggestionsController < ApplicationController
  def suggest
    return render(json: { error: "Bad request" }, status: :bad_request) if params_invalid?

    sanitised_query = CGI.escape(params[:query])
    suggestions = ProviderSuggestion.suggest(sanitised_query)
      .map { |provider| { code: provider.provider_code, name: provider.provider_name } }
    render json: suggestions
  end

  def suggest_any
    return render(json: { error: "Bad request" }, status: :bad_request) if params_invalid?

    sanitised_query = CGI.escape(params[:query])
    suggestions = ProviderSuggestion.suggest_any(sanitised_query)
      .map { |provider| { code: provider.provider_code, name: provider.provider_name } }
    render json: suggestions
  end

private

  def params_invalid?
    params[:query].nil? || params[:query].length < 3
  end
end
