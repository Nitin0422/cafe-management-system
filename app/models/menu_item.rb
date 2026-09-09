# frozen_string_literal: true

class MenuItem < ApplicationRecord
  include Attributable

  # Form-facing price in rupees (NPR). The admin form collects the price in
  # rupees and the controller converts it to price_cents (paisa) before save.
  # The submitted value is retained so the form can re-display it when
  # validation fails; existing records fall back to the stored price.
  attr_writer :price_rupees

  belongs_to :category
  has_many :recipe_items, dependent: :destroy
  has_many :ingredients, through: :recipe_items
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :category, presence: true

  def price_rupees
    @price_rupees || (price_cents / 100.0 if price_cents)
  end
end
