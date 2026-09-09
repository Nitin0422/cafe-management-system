# frozen_string_literal: true

# Shared authentication helpers for request specs. `log_in` signs the given
# user in through the real login form, just as SessionsController#create does,
# so request specs can exercise authorization without going through the UI.
module AuthenticationHelpers
  def log_in(user)
    post login_path, params: { email: user.email, password: "password123" }
  end

  # Signs a user in directly through a test-only endpoint. Needed for roles
  # that cannot log in via the email+password form (customers; customer login
  # is T7) so authorization specs can still exercise guards with a session
  # belonging to that role.
  def log_in_directly(user)
    get test_login_as_path(user)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
