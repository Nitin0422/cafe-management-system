# frozen_string_literal: true

class RecipeItem < ApplicationRecord
  include Attributable

  belongs_to :menu_item
  belongs_to :ingredient

  validates :quantity, numericality: { greater_than: 0 }
  validates :menu_item_id, uniqueness: { scope: :ingredient_id }
end
