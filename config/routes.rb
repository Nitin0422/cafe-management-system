Rails.application.routes.draw do
  # Session management (login / logout)
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Test-only guard endpoints for authorization specs. These are only mounted
  # in the test environment so request specs can exercise require_admin and
  # require_any_employee before real feature controllers exist (T4+).
  if Rails.env.test?
    get "guard/admin"    => "guard_echo#admin_only"
    get "guard/employee" => "guard_echo#employee_only"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "pages#home"
end
