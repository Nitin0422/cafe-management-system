# frozen_string_literal: true

# Shared authentication helpers for request specs. `log_in` signs the given
# user in by setting the session value just as SessionsController#create does,
# so request specs can exercise authorization without going through the UI.
module AuthenticationHelpers
  def log_in(user)
    post login_path, params: { email: user.email, password: "password123" }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
