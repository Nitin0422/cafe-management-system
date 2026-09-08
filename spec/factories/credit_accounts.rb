# frozen_string_literal: true

FactoryBot.define do
  factory :credit_account do
    user
    balance_cents { 0 }
    status { :active }
  end
end
