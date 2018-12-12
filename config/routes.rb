Rails.application.routes.draw do
  # DfE Sign In
  get "/signin", to: "sessions#new", as: "signin"
  get "/signout", to: "sessions#signout", as: "signout"
  get "/auth/dfe/callback", to: "sessions#create"
  get "/auth/dfe/signout", to: "sessions#destroy"

  root to: "pages#home"

  get "/pages/:page", to: "pages#show"

  get "/cookies", to: "pages#cookies", as: :cookies
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/privacy-policy", to: "pages#privacy", as: :privacy

  match '/404', to: 'errors#not_found', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
