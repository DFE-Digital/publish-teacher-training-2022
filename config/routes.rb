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


      # redirect back to manage course ui
      get '/preview', to: redirect("#{Settings.manage_ui.base_url}/organisation/%{provider_code}/course/self/%{course_code}/preview", status: 302)
      get '/about', to: redirect("#{Settings.manage_ui.base_url}/organisation/%{provider_code}/course/self/%{course_code}/about", status: 302)
      get '/requirements', to: redirect("#{Settings.manage_ui.base_url}/organisation/%{provider_code}/course/self/%{course_code}/requirements", status: 302)
      get '/salary', to: redirect("#{Settings.manage_ui.base_url}/organisation/%{provider_code}/course/self/%{course_code}/salary", status: 302)
      get '/fees-and-length', to: redirect("#{Settings.manage_ui.base_url}/organisation/%{provider_code}/course/self/%{course_code}/fees-and-length", status: 302)
      get '/', to: redirect("#{Settings.manage_ui.base_url}/organisation/%{provider_code}/course/self/%{course_code}", status: 302)
    end
  end

  get "/cookies", to: "pages#cookies", as: :cookies
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/privacy-policy", to: "pages#privacy", as: :privacy

  match '/404', to: 'errors#not_found', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
