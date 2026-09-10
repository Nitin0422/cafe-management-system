# frozen_string_literal: true

module Admin
  # Stock entry recording (T6). Staff and admins record restock/purchase and
  # stock corrections against an ingredient. The stock_entries table is an
  # immutable ledger: entries are only appended (no edit or destroy), and
  # current stock is derived by summing the ledger. Restock entries must add
  # stock (positive quantity); corrections may adjust up or down.
  class StockEntriesController < ApplicationController
    before_action :require_any_employee
    before_action :set_ingredients, only: %i[new create]

    def index
      @stock_entries = StockEntry.includes(:ingredient, :created_by).order(created_at: :desc, id: :desc)
    end

    def new
      @stock_entry = StockEntry.new
    end

    def create
      # entry_type is submitted as a string ("restock" / "correction"); a nil
      # or unknown value is rejected rather than defaulting to a silent add.
      entry_type = params.dig(:stock_entry, :entry_type)
      unless %w[restock correction].include?(entry_type)
        @stock_entry = StockEntry.new(entry_type: nil)
        @stock_entry.errors.add(:entry_type, "must be restock or correction")
        render :new, status: :unprocessable_content
        return
      end

      @stock_entry = StockEntry.new(stock_entry_params)
      @stock_entry.entry_type = entry_type

      if @stock_entry.save
        redirect_to admin_stock_entries_path, notice: "Stock entry recorded for #{@stock_entry.ingredient.name}."
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def set_ingredients
      @ingredients = Ingredient.order(:name, :id)
    end

    def stock_entry_params
      params.require(:stock_entry).permit(:ingredient_id, :quantity, :reference, :note)
    end
  end
end
