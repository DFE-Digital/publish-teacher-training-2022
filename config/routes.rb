Rails.application.routes.draw do
  constraints(host: /www2\.|\.education\./) do
    match "/(*path)" => redirect { |_, req| "#{Settings.dfe_signin.base_url}#{req.fullpath}" },
          via: %i[get post put]
  end

  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat

  # Old links
  get "/signin", to: redirect("/sign-in")
  get "/signout", to: redirect("/sign-out")

  get "/sign-in", to: "sign_in#index"
  get "/sign-out", to: "sessions#signout"

  if AuthenticationService.magic_link?
    post "/send_magic_link", to: "sessions#send_magic_link"
    get "/magic_link_sent", to: "sessions#magic_link_sent"
    get "/signin_with_magic_link", to: "sessions#create_by_magic", as: "signin_with_magic_link"
  elsif AuthenticationService.persona?
    get "/personas", to: "personas#index"
    post "/auth/developer/callback", to: "sessions#create"
    get "/auth/developer/signout", to: "sessions#destroy"
  else
    get "/auth/dfe/callback", to: "sessions#create"
    get "/auth/dfe/signout", to: "sessions#destroy"
  end

  get "/auth/failure", to: "sessions#failure"

  root to: "providers#index"
  get "/organisations", to: redirect("/")

  resources :notifications, path: "/notifications", controller: "notifications", only: %i[index update]

  resources :access_requests, path: "/access-requests", controller: "access_requests", only: %i[new index create] do
    member do
      post :approve
      delete :destroy
      get :confirm
      get "/inform-publisher", to: "access_requests#inform_publisher"
    end
  end

  get "organisations-support-page", to: "organisations#index"

  resources :providers, path: "organisations", param: :code do
    # Redirect year-less URLs to current recruitment cycle
    get "/locations", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/locations")
    get "/locations/:location_id/edit", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/locations/%{location_id}/edit")
    get "/locations/new", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/locations/new")
    get "/courses", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses")
    get "/courses/:course_code", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}")
    get "/courses/:course_code/locations", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/locations")
    get "/courses/:course_code/vacancies", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/vacancies")
    get "/courses/:course_code/about", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/about")
    get "/courses/:course_code/details", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/details")
    get "/courses/:course_code/fees", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/fees")
    get "/courses/:course_code/salary", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/salary")
    get "/courses/:course_code/requirements", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/requirements")
    get "/courses/:course_code/withdraw", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/withdraw")
    get "/courses/:course_code/delete", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/delete")
    get "/courses/:course_code/preview", to: redirect("/organisations/%{provider_code}/#{Settings.current_cycle}/courses/%{course_code}/preview")

    get "/request-access", on: :member, to: "providers/access_requests#new"
    post "/request-access", on: :member, to: "providers/access_requests#create"

    get "/users", on: :member, to: "providers/users#index"

    resources :recruitment_cycles, param: :year, constraints: { year: /#{Settings.current_cycle}|#{Settings.current_cycle + 1}/ }, path: "", only: :show do
      get "/details", on: :member, to: "providers#details"
      get "/contact", on: :member, to: "providers#contact"
      put "/contact", on: :member, to: "providers#update"
      get "/about", on: :member, to: "providers#about"
      put "/about", on: :member, to: "providers#update"
      post "/publish", on: :member, to: "providers#publish"
      get "/training-providers", on: :member, to: "providers#training_providers"
      get "/training-providers-courses", on: :member, to: "training_providers_courses#index", as: "download_training_providers_courses"
      get "/visas", to: "providers/visas#edit"
      post "/visas", to: "providers/visas#update"
      get "/references", to: "providers/references#edit"
      post "/references", to: "providers/references#update"

      resource :training_providers, path: "/training-providers", on: :member, param: :code, only: [], as: "" do
        get "/:training_provider_code/courses", to: "providers#training_provider_courses", as: "training_provider_courses"
      end

      resource :courses, only: %i[create] do
        resource :outcome, on: :member, only: %i[new], controller: "courses/outcome" do
          get "continue"
        end
        resource :entry_requirements, on: :member, only: %i[new], controller: "courses/entry_requirements", path: "entry-requirements" do
          get "continue"
        end
        resource :study_mode, on: :member, only: %i[new], controller: "courses/study_mode", path: "full-part-time" do
          get "continue"
        end
        resource :level, on: :member, only: %i[new], controller: "courses/level" do
          get "continue"
        end
        resource :locations, on: :member, only: %i[new], controller: "courses/sites" do
          get "back"
          get "continue"
        end
        resource :start_date, on: :member, only: %i[new], controller: "courses/start_date", path: "start-date" do
          get "continue"
        end
        resource :applications_open, on: :member, only: %i[new], controller: "courses/applications_open", path: "applications-open" do
          get "continue"
        end
        resource :age_range, on: :member, only: %i[new], controller: "courses/age_range", path: "age-range" do
          get "continue"
        end
        resource :subjects, on: :member, only: %i[new], controller: "courses/subjects", path: "subjects" do
          get "continue"
        end
        resource :modern_languages, on: :member, only: %i[new], controller: "courses/modern_languages", path: "modern-languages" do
          get "back"
          get "continue"
        end
        resource :apprenticeship, on: :member, only: %i[new], controller: "courses/apprenticeship" do
          get "continue"
        end
        resource :accredited_body, on: :member, only: %i[new], controller: "courses/accredited_body", path: "accredited-body" do
          get "continue"
          get "search_new"
        end
        resource :fee_or_salary, on: :member, only: %i[new], controller: "courses/fee_or_salary", path: "fee-or-salary" do
          get "continue"
        end
        get "confirmation"
      end

      resources :courses, param: :code do
        delete "/", on: :member, to: "courses#destroy"

        get "/vacancies", on: :member, to: "courses/vacancies#edit"
        put "/vacancies", on: :member, to: "courses/vacancies#update"
        get "/details", on: :member, to: "courses#details"

        get "/about", on: :member, to: "courses#about"
        patch "/about", on: :member, to: "courses#update"
        get "/requirements", on: :member, to: "courses#requirements"
        patch "/requirements", on: :member, to: "courses#update"
        get "/fees", on: :member, to: "courses#fees"
        patch "/fees", on: :member, to: "courses#update"
        get "/salary", on: :member, to: "courses#salary"
        patch "/salary", on: :member, to: "courses#update"

        get "/withdraw", on: :member, to: "courses#withdraw_course"
        post "/withdraw", on: :member, to: "courses#withdraw_course"

        get "/delete", on: :member, to: "courses#delete"
        get "/preview", on: :member, to: "courses#preview"
        get "/locations", on: :member, to: "courses/sites#edit"
        put "/locations", on: :member, to: "courses/sites#update"
        get "/publish", on: :member, to: "courses#details"
        post "/publish", on: :member, to: "courses#publish"

        get "/entry-requirements", on: :member, to: "courses/entry_requirements#edit"
        put "/entry-requirements", on: :member, to: "courses/entry_requirements#update"

        get "/outcome", on: :member, to: "courses/outcome#edit"
        put "/outcome", on: :member, to: "courses/outcome#update"

        get "/accredited-body", on: :member, to: "courses/accredited_body#edit"
        put "/accredited-body", on: :member, to: "courses/accredited_body#update"
        get "/accredited-body/search", on: :member, to: "courses/accredited_body#search"

        get "/subjects", on: :member, to: "courses/subjects#edit"
        put "/subjects", on: :member, to: "courses/subjects#update"

        get "/modern-languages", on: :member, to: "courses/modern_languages#edit"
        put "/modern-languages", on: :member, to: "courses/modern_languages#update"

        get "/age-range", on: :member, to: "courses/age_range#edit"
        put "/age-range", on: :member, to: "courses/age_range#update"

        get "/start-date", on: :member, to: "courses/start_date#edit"
        put "/start-date", on: :member, to: "courses/start_date#update"

        get "/applications-open", on: :member, to: "courses/applications_open#edit"
        put "/applications-open", on: :member, to: "courses/applications_open#update"

        get "/send", on: :member, to: "courses/send#edit"
        put "/send", on: :member, to: "courses/send#update"

        get "/apprenticeship", on: :member, to: "courses/apprenticeship#edit"
        put "/apprenticeship", on: :member, to: "courses/apprenticeship#update"

        get "/fee-or-salary", on: :member, to: "courses/fee_or_salary#edit"
        put "/fee-or-salary", on: :member, to: "courses/fee_or_salary#update"

        get "/full-part-time", on: :member, to: "courses/study_mode#edit"
        put "/full-part-time", on: :member, to: "courses/study_mode#update"

        get "/request-change", on: :member, to: "courses#request_change"

        get "/degrees/start", on: :member, to: "courses/degrees/start#edit"
        put "/degrees/start", on: :member, to: "courses/degrees/start#update"

        get "/degrees/grade", on: :member, to: "courses/degrees/grade#edit"
        put "/degrees/grade", on: :member, to: "courses/degrees/grade#update"

        get "/degrees/subject-requirements", on: :member, to: "courses/degrees/subject_requirements#edit"
        put "/degrees/subject-requirements", on: :member, to: "courses/degrees/subject_requirements#update"

        get "/gcses-pending-or-equivalency-tests", on: :member, to: "courses/gcse_requirements#edit"
        put "/gcses-pending-or-equivalency-tests", on: :member, to: "courses/gcse_requirements#update"
      end

      resources :sites, path: "locations", on: :member, except: %i[destroy show]

      scope module: "providers" do
        resources :allocations, only: %i[index], on: :member, param: :training_provider_code do
          collection do
            get :initial_request, path: "request"
            post :initial_request, path: "request"
          end

          member do
            get :new_repeat_request, path: "new-repeat-request"
            post :create
            get :show
            get :edit, path: "edit", param: :id
            patch :update

            scope :initial_requests do
              get :edit, to: "edit_initial_allocations#edit", as: "get_edit_initial_request"
              post :edit, to: "edit_initial_allocations#edit", as: "post_edit_initial_request"
              post :update, to: "edit_initial_allocations#update", as: "update_initial_request"
              get :delete, to: "edit_initial_allocations#delete", as: "delete_initial_request"
              get :confirm_deletion, to: "edit_initial_allocations#confirm_deletion"
            end
          end
        end
      end
    end
  end

  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/cookies", to: "pages#cookies", as: :cookies
  get "/terms-conditions", to: "pages#terms", as: :terms
  get "/privacy-policy", to: "pages#privacy", as: :privacy
  get "/guidance", to: "pages#guidance", as: :guidance
  get "/notifications-info", to: "pages#notifications_info", as: :notifications_info
  patch "/accept-notifications-info", to: "users#accept_notifications_info"
  get "/transition-info", to: "pages#transition_info", as: :transition_info
  patch "/accept-transition-info", to: "users#accept_transition_info"
  get "/rollover", to: "pages#rollover", as: :rollover
  get "/rollover-recruitment", to: "pages#rollover_recruitment", as: :rollover_recruitment
  patch "/accept-rollover", to: "users#accept_rollover"
  patch "/accept-rollover-recruitment", to: "users#accept_rollover_recruitment"
  get "/accept-terms", to: "pages#accept_terms"
  patch "/accept-terms", to: "users#accept_terms"
  get "/performance-dashboard", to: "pages#performance_dashboard", as: :performance_dashboard

  get "/providers/suggest", to: "provider_suggestions#suggest"
  get "/providers/suggest_any", to: "provider_suggestions#suggest_any"
  get "/providers/suggest_any_accredited_body", to: "provider_suggestions#suggest_any_accredited_body"
  get "/providers/search", to: "providers#search"

  match "/401", to: "errors#unauthorized", via: :all, as: "unauthorized"
  match "/403", to: "errors#forbidden", via: :all
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "*path", to: "errors#not_found", via: :all
end
