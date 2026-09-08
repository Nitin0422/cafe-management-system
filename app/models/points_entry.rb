# frozen_string_literal: true

class PointsEntry < ApplicationRecord
  include Attributable

  enum :entry_type, { accrual: 0, redemption: 1 }

  belongs_to :user
  belongs_to :order, optional: true

  validates :quantity, numericality: { only_integer: true, other_than: 0 }
  validates :entry_type, inclusion: { in: entry_types.keys }
  validates :created_by, presence: true
end
