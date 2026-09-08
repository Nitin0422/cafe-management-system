# frozen_string_literal: true

class Payment < ApplicationRecord
  include Attributable

  enum :payment_type, { cash: 0, card: 1, other: 2 }

  belongs_to :order

  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :payment_type, inclusion: { in: payment_types.keys }
  validates :created_by, presence: true
end
