# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    order
    menu_item
    quantity { 1 }
    unit_price_cents { 25_000 }
    subtotal_cents { 25_000 }
    redeemed { false }
  end
end
