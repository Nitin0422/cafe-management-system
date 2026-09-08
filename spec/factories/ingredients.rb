# frozen_string_literal: true

FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "Ingredient #{n}" }
    unit { "g" }
    low_stock_threshold { 0 }
  end
end
