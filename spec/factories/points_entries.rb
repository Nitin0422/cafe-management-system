# frozen_string_literal: true

FactoryBot.define do
  factory :points_entry do
    user factory: :user
    quantity { 100 }
    entry_type { :accrual }
    order { nil }
    description { nil }
    created_by factory: :user
  end
end
