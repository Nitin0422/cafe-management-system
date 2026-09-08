# frozen_string_literal: true

class MenuItem < ApplicationRecord
  include Attributable

  belongs_to :category
  has_many :recipe_items, dependent: :destroy
  has_many :ingredients, through: :recipe_items
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :category, presence: true
end
