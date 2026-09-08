# frozen_string_literal: true

FactoryBot.define do
  factory :stock_entry do
    ingredient
    quantity { 100 }
    entry_type { :restock }
    reference { nil }
    note { nil }
    created_by factory: :user
  end
end
