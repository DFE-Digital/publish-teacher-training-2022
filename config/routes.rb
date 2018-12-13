Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"

  get "/cookies", to: "pages#cookies", as: :cookies
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/privacy-policy", to: "pages#privacy", as: :privacy
end
