Rails.application.routes.draw do
  # DfE Sign In
  get "/signin", to: "sessions#new", as: "signin"
  get "/signout", to: "sessions#signout", as: "signout"
  get "/auth/dfe/callback", to: "sessions#create"
  get "/auth/dfe/signout", to: "sessions#destroy"
  get "/auth/failure", to: "sessions#failure"

  root to: "providers#index"

  resources :providers, path: 'organisations', param: :code do
    resources :courses, param: :code do
      get '/vacancies', on: :member, to: 'courses/vacancies#edit'
      put '/vacancies', on: :member, to: 'courses/vacancies#update'
      get '/withdraw', on: :member, to: 'courses#withdraw'
      get '/delete', on: :member, to: 'courses#delete'
    end

    resources :sites, path: 'locations', on: :member, only: %i[index edit update]
  end

  get "/cookies", to: "pages#cookies", as: :cookies
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/guidance", to: "pages#guidance", as: :guidance
  get "/transition", to: "pages#transition", as: :transition

  match '/404', to: 'errors#not_found', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
