Rails.application.routes.draw do
  # Session management (login / logout)
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Customer self-service registration (T7, FR-1). Customers register with
  # email AND phone plus a password.
  get  "register", to: "registrations#new",     as: :register
  post "register", to: "registrations#create"

  # Customer login (T7, FR-7). A distinct entry point from the employee
  # email+password login: customers sign in with email OR phone + password.
  get  "customer/login", to: "customer_sessions#new",     as: :customer_login
  post "customer/login", to: "customer_sessions#create"

  # Counter-side customer registration (T7, PRD assumption). Any employee may
  # create a customer account when none exists.
  namespace :staff do
    resources :customers, only: %i[new create]
  end

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

    # Inventory management (T6). Ingredients and recipes are admin-only; stock
    # entries (an immutable ledger) may be recorded by any employee so staff
    # can restock or correct stock at the counter.
    resources :ingredients, only: %i[index new create edit update]
    resources :recipe_items, only: %i[index new create edit update destroy]
    resources :stock_entries, only: %i[index new create]
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
