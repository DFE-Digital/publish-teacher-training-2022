# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  # DfE Sign In
  get "/signin", to: "sessions#new", as: "signin"
  get "/signout", to: "sessions#signout", as: "signout"
  get "/auth/dfe/callback", to: "sessions#create"
  get "/auth/dfe/signout", to: "sessions#destroy"
  get "/auth/failure", to: "sessions#failure"

  root to: "providers#index"

  resources :providers, path: 'organisations', param: :code do
    # Redirect legacy URLS to default recruitment cycle i.e. 2019
    get '/locations', to: redirect('/organisations/%{provider_code}/2019/locations')
    get '/locations/:location_id/edit', to: redirect('/organisations/%{provider_code}/2019/locations/%{location_id}/edit')
    get '/locations/new', to: redirect('/organisations/%{provider_code}/2019/locations/new')
    get '/courses/:course_code', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}')
    get '/courses/:course_code/locations', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/locations')
    get '/courses/:course_code/vacancies', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/vacancies')
    get '/courses/:course_code/about', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/about')
    get '/courses/:course_code/details', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/details')
    get '/courses/:course_code/fees', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/fees')
    get '/courses/:course_code/salary', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/salary')
    get '/courses/:course_code/requirements', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/requirements')
    get '/courses/:course_code/withdraw', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/withdraw')
    get '/courses/:course_code/delete', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/delete')
    get '/courses/:course_code/preview', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/preview')

    resources :recruitment_cycles, param: :year, path: '', only: :show do
      resources :courses, param: :code do
        get '/vacancies', on: :member, to: 'courses/vacancies#edit'
        put '/vacancies', on: :member, to: 'courses/vacancies#update'
        get '/details', on: :member, to: 'courses#details'

        get '/about', on: :member, to: 'courses#about'
        patch '/about', on: :member, to: 'courses#update'
        get '/requirements', on: :member, to: 'courses#requirements'
        patch '/requirements', on: :member, to: 'courses#update'
        get '/fees', on: :member, to: 'courses#fees'
        patch '/fees', on: :member, to: 'courses#update'
        get '/salary', on: :member, to: 'courses#salary'
        patch '/salary', on: :member, to: 'courses#update'

        get '/withdraw', on: :member, to: 'courses#withdraw'
        get '/delete', on: :member, to: 'courses#delete'
        get '/preview', on: :member, to: 'courses#preview'
        get '/locations', on: :member, to: 'courses/sites#edit'
        put '/locations', on: :member, to: 'courses/sites#update'
        post '/publish', on: :member, to: 'courses#publish'
      end

      resources :sites, path: 'locations', on: :member, except: %i[destroy show]
    end
  end

  get "/cookies", to: "pages#cookies", as: :cookies
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/guidance", to: "pages#guidance", as: :guidance
  get "/new-features", to: "pages#new_features", as: :new_features
  get "/transition-info", to: "pages#transition_info", as: :transition_info
  patch '/accept-transition-info', to: 'users#accept_transition_info'
  get "/rollover", to: "pages#rollover", as: :rollover
  patch '/accept-rollover', to: 'users#accept_rollover'

  match '/404', to: 'errors#not_found', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
# rubocop:enable Metrics/BlockLength
