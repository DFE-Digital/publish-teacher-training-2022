# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  constraints(host: /www2\.|\.education\./) do
    match "/(*path)" => redirect { |_, req| "#{Settings.dfe_signin.base_url}#{req.fullpath}" },
      via: %i[get post put]
  end

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
    get '/courses', to: redirect('/organisations/%{provider_code}/2019/courses')
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

    get '/request-access', on: :member, to: 'access_requests#new'
    post '/request-access', on: :member, to: 'access_requests#create'

    # TODO: Extract year constraint to future proof for future cycles
    resources :recruitment_cycles, param: :year, constraints: { year: /2019|2020/ }, path: '', only: :show do
      get '/details', on: :member, to: 'providers#details'
      get '/contact', on: :member, to: 'providers#contact'
      put '/contact', on: :member, to: 'providers#update'
      get '/about', on: :member, to: 'providers#about'
      put '/about', on: :member, to: 'providers#update'
      post '/publish', on: :member, to: 'providers#publish'

      resource :courses, only: [] do
        resource :outcome, on: :member, only: %i[new], controller: 'courses/outcome' do
          get 'continue'
        end
        resource :entry_requirements, on: :member, only: %i[new], controller: 'courses/entry_requirements', path: 'entry-requirements' do
          get 'continue'
        end
        resource :study_mode, on: :member, only: %i[new], controller: 'courses/study_mode', path: 'full-part-time' do
          get 'continue'
        end
        resource :level, on: :member, only: %i[new], controller: 'courses/level' do
          get 'continue'
        end
        resource :start_date, on: :member, only: %i[new], controller: 'courses/start_date', path: 'start-date' do
          get 'continue'
        end
        resource :applications_open, on: :member, only: %i[new], controller: 'courses/applications_open', path: 'applications-open' do
          get 'continue'
        end
        resource :age_range, on: :member, only: %i[new], controller: 'courses/age_range', path: 'age-range' do
          get 'continue'
        end
        resource :apprenticeship, on: :member, only: %i[new], controller: 'courses/apprenticeship' do
          get 'continue'
        end
        resource :fee_or_salary, on: :member, only: %i[new], controller: 'courses/fee_or_salary', path: 'fee-or-salary' do
          get 'continue'
        end
        get 'confirmation'
      end

      resources :courses, param: :code do
        delete '/', on: :member, to: 'courses#destroy'

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
        get '/publish', on: :member, to: 'courses#details'
        post '/publish', on: :member, to: 'courses#publish'

        get '/entry-requirements', on: :member, to: 'courses/entry_requirements#edit'
        put '/entry-requirements', on: :member, to: 'courses/entry_requirements#update'

        get '/outcome', on: :member, to: 'courses/outcome#edit'
        put '/outcome', on: :member, to: 'courses/outcome#update'

        get '/accredited-body', on: :member, to: 'courses/accredited_body#edit'
        put '/accredited-body', on: :member, to: 'courses/accredited_body#update'
        get '/accredited-body/search', on: :member, to: 'courses/accredited_body#search'

        get '/age-range', on: :member, to: 'courses/age_range#edit'
        put '/age-range', on: :member, to: 'courses/age_range#update'

        get '/start-date', on: :member, to: 'courses/start_date#edit'
        put '/start-date', on: :member, to: 'courses/start_date#update'

        get '/applications-open', on: :member, to: 'courses/applications_open#edit'
        put '/applications-open', on: :member, to: 'courses/applications_open#update'

        get '/send', on: :member, to: 'courses/send#edit'
        put '/send', on: :member, to: 'courses/send#update'

        get '/apprenticeship', on: :member, to: 'courses/apprenticeship#edit'
        put '/apprenticeship', on: :member, to: 'courses/apprenticeship#update'

        get '/fee-or-salary', on: :member, to: 'courses/fee_or_salary#edit'
        put '/fee-or-salary', on: :member, to: 'courses/fee_or_salary#update'

        get '/full-part-time', on: :member, to: 'courses/study_mode#edit'
        put '/full-part-time', on: :member, to: 'courses/study_mode#update'

        get '/request-change', on: :member, to: 'courses#request_change'
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
  get "/accept-terms", to: "pages#accept_terms"
  patch '/accept-terms', to: 'users#accept_terms'

  # redirect URL's from legacy c# app
  get '/organisation/:provider_code', to: redirect('/organisations/%{provider_code}', status: 301)
  get '/organisation/:provider_code/details', to: redirect('/organisations/%{provider_code}/details', status: 301)
  get '/organisation/:provider_code/contact', to: redirect('/organisations/%{provider_code}/contact', status: 301)
  get '/organisation/:provider_code/request-access', to: redirect('/organisations/%{provider_code}/request-access', status: 301)
  get '/organisation/:provider_code/course/self/:course_code', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}', status: 301)
  get '/organisation/:provider_code/course/:accrediting_provider/:course_code', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}', status: 301)
  get '/organisation/:provider_code/course/self/:course_code/about', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/about', status: 301)
  get '/organisation/:provider_code/course/:accrediting_provider/:course_code/about', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/about', status: 301)
  get '/organisation/:provider_code/course/self/:course_code/fees-and-length', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/fees', status: 301)
  get '/organisation/:provider_code/course/:accrediting_provider/:course_code/fees-and-length', to: redirect('/organisations/%{provider_code}/2019/courses/%{course_code}/fees', status: 301)
  get '/auth/cb', to: redirect('/', status: 301)

  match '/401', to: 'errors#unauthorized', via: :all, as: 'unauthorized'
  match '/404', to: 'errors#not_found', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
# rubocop:enable Metrics/BlockLength
