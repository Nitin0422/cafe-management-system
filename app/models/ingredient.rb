# frozen_string_literal: true

class Ingredient < ApplicationRecord
  include Attributable

  has_many :recipe_items, dependent: :restrict_with_error
  has_many :menu_items, through: :recipe_items
  has_many :stock_entries, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :unit, presence: true
  validates :low_stock_threshold, numericality: { greater_than_or_equal_to: 0 }

  # Stock is derived entirely from the stock_entries ledger: no denormalized
  # current-stock column exists.
  def current_stock
    stock_entries.sum(:quantity)
  end

  def low_stock?
    current_stock <= low_stock_threshold
  end
end
