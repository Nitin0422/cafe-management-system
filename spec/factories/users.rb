# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:phone) { |n| format("+977-98%08d", n) }
    password { "password123" }
    full_name { "Test User" }
    role { :customer }
    active { true }

    trait :admin do
      role { :admin }
    end

    trait :staff do
      role { :staff }
      sequence(:email) { |n| "staff#{n}@example.com" }
    end

    trait :customer do
      role { :customer }
      sequence(:email) { |n| "customer#{n}@example.com" }
    end
  end
end
