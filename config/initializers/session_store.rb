# frozen_string_literal: true

# Expire sessions after 8 hours of inactivity. The cookie_store stores the
# session in a signed, encrypted cookie on the client; expire_after controls
# its lifetime. Users must log in again after the cookie expires.
Rails.application.config.session_store :cookie_store, expire_after: 8.hours
