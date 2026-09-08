# frozen_string_literal: true

class StockEntry < ApplicationRecord
  include Attributable

  enum :entry_type, { restock: 0, correction: 1, sale_decrement: 2 }

  belongs_to :ingredient

  validates :quantity, numericality: { other_than: 0 }
  validates :entry_type, inclusion: { in: entry_types.keys }
  validates :created_by, presence: true
end
