# frozen_string_literal: true

class OrderItem < ApplicationRecord
  include Attributable

  belongs_to :order
  belongs_to :menu_item

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :unit_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :subtotal_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
