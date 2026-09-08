# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    order
    amount_cents { 10_000 }
    payment_type { :cash }
    reference { nil }
    created_by factory: :user
  end
end
