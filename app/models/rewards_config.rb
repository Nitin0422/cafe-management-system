# frozen_string_literal: true

# Singleton configuration row: exactly one rewards configuration may exist
# (seeded as id 1). Controls the points-per-rupee accrual rate.
class RewardsConfig < ApplicationRecord
  include Attributable

  validates :points_per_rupee, numericality: { greater_than_or_equal_to: 0 }
  validate :ensure_singleton

  private

  def ensure_singleton
    errors.add(:base, "only one rewards configuration is allowed") if self.class.where.not(id: id).exists?
  end
end
