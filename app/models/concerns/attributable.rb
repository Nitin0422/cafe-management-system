# frozen_string_literal: true

# Attribution concern (FR-12). Adds created_by/updated_by associations to the
# acting user and stamps them from Current.user on create/update.
#
# Associations are optional here; models that require attribution (orders,
# payments, stock_entries, tab_payments, points_entries) enforce presence with
# their own validation.
module Attributable
  extend ActiveSupport::Concern

  included do
    belongs_to :created_by, class_name: "User", optional: true, inverse_of: false
    belongs_to :updated_by, class_name: "User", optional: true, inverse_of: false

    # Stamped in before_validation so attribution is set before the model's
    # own presence validation runs (before_create would run after validation,
    # leaving created_by blank during validation for mandatory-attribution
    # models such as Order).
    before_validation :set_created_by, on: :create
    before_save :set_updated_by
  end

  private

  def set_created_by
    self.created_by ||= Current.user
  end

  # updated_by always reflects the actor on the most recent save, so it is
  # overwritten (not ||=) whenever an actor is present.
  def set_updated_by
    self.updated_by = Current.user if Current.user
  end
end
