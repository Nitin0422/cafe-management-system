Rails.application.routes.draw do
  # Session management (login / logout)
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Admin staff-account management (T4). Only admins may manage staff accounts.
  # Admin menu management (T5). Only admins may manage menu items; deactivate
  # soft-hides an item by flipping `available` to false rather than deleting it.
  namespace :admin do
    resources :users, only: %i[index new create] do
      member { post :deactivate }
    end

    resources :menu_items, only: %i[index new create edit update] do
      member { post :deactivate }
    end
  end

  # Test-only guard endpoints for authorization specs. These are only mounted
  # in the test environment so request specs can exercise require_admin and
  # require_any_employee before real feature controllers exist (T4+).
  if Rails.env.test?
    get "guard/admin"    => "guard_echo#admin_only"
    get "guard/employee" => "guard_echo#employee_only"
    get "test/login_as/:user_id" => "test_sessions#create", as: :test_login_as
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "pages#home"
end
