# frozen_string_literal: true

module Admin
  # Admin ingredient management (T6). Only admins may create or edit
  # ingredients. Each ingredient carries a single stock unit and a low-stock
  # threshold; current stock is derived from the stock_entries ledger, so this
  # controller manages ingredient definitions only (stock is adjusted via
  # Admin::StockEntriesController).
  class IngredientsController < ApplicationController
    before_action :require_admin
    before_action :set_ingredient, only: %i[edit update]

    def index
      @ingredients = Ingredient.includes(:stock_entries).order(:name, :id)
    end

    def new
      @ingredient = Ingredient.new
    end

    def create
      @ingredient = Ingredient.new(ingredient_params)

      if @ingredient.save
        redirect_to admin_ingredients_path, notice: "Ingredient created: #{@ingredient.name}."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit; end

    def update
      if @ingredient.update(ingredient_params)
        redirect_to admin_ingredients_path, notice: "#{@ingredient.name} has been updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end

    def ingredient_params
      params.require(:ingredient).permit(:name, :unit, :low_stock_threshold)
    end
  end
end
