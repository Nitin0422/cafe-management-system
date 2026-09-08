# frozen_string_literal: true

FactoryBot.define do
  factory :menu_item do
    sequence(:name) { |n| "Menu Item #{n}" }
    description { nil }
    price_cents { 25_000 }
    category
    available { true }
    redeemable { false }
  end
end
