# frozen_string_literal: true

FactoryBot.define do
  factory :tab_payment do
    credit_account
    amount_cents { 10_000 }
    payment_type { :cash }
    reference { nil }
    note { nil }
    created_by factory: :user
  end
end
