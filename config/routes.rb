Rails.application.routes.draw do
  # DfE Sign In
  get "/login", to: redirect('/auth/dfe'), as: "login"
  get "/logout", to: "sessions#destroy", as: "logout"
  get "/auth/dfe/callback", to: "sessions#create"

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
