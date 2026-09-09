# frozen_string_literal: true

class StockEntry < ApplicationRecord
  include Attributable

  enum :entry_type, { restock: 0, correction: 1, sale_decrement: 2 }

  belongs_to :ingredient

  validates :quantity, numericality: { other_than: 0 }
  validates :entry_type, inclusion: { in: entry_types.keys }
  validates :created_by, presence: true

  # Record a sale_decrement ledger entry for every ingredient in the given
  # menu item's recipe, applying the recipe quantity per unit sold. Called by
  # the point-of-sale flow (T12) so stock is decremented automatically when an
  # order is completed. Raises on failure (create!) so a failed decrement
  # aborts the enclosing transaction rather than silently leaving stock
  # unchanged. Menu items with no recipe items decrement nothing.
  def self.decrement_for_sale!(menu_item:, quantity: 1)
    menu_item.recipe_items.each do |recipe_item|
      create!(
        ingredient: recipe_item.ingredient,
        quantity: -(recipe_item.quantity * quantity),
        entry_type: :sale_decrement
      )
    end
  end
end
