# frozen_string_literal: true

FactoryBot.define do
  factory :recipe_item do
    menu_item
    ingredient
    quantity { 1 }
  end
end
