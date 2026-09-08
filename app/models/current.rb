# frozen_string_literal: true

# Holds request-scoped attributes (the acting user) so that the Attributable
# concern can stamp created_by/updated_by without threading the user through
# every call site. T3 wires Current.user from the authenticated session.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
