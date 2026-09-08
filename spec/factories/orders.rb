# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    status { :draft }
    total_cents { 0 }
    closure_type { nil }
    customer factory: :user
    closed_by { nil }
    closed_at { nil }
    created_by factory: :user
  end
end
