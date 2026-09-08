# frozen_string_literal: true

# Ensure Current.user does not leak between examples. The attribution concern
# reads Current.user when setting created_by/updated_by, so any value set in
# one example must not affect subsequent examples.
RSpec.configure do |config|
  config.after(:each) do
    Current.reset
  end
end