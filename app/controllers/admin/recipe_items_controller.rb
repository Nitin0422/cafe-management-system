# frozen_string_literal: true

module Admin
  # Admin recipe management (T6). A recipe maps a menu item to the ingredients
  # and quantities required to make it. Only admins may define or edit recipes;
  # a recipe line can be edited in place or removed with destroy.
  class RecipeItemsController < ApplicationController
    before_action :require_admin
    before_action :set_recipe_item, only: %i[edit update destroy]
    before_action :set_menu_items_and_ingredients, only: %i[new create edit update]

    def index
      @recipe_items = RecipeItem.includes(:menu_item, :ingredient).order("menu_items.name, ingredients.name, recipe_items.id")
    end

    def new
      @recipe_item = RecipeItem.new
    end

    def create
      @recipe_item = RecipeItem.new(recipe_item_params)

      if @recipe_item.save
        redirect_to admin_recipe_items_path, notice: "Recipe line added: #{@recipe_item.ingredient.name} for #{@recipe_item.menu_item.name}."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit; end

    def update
      if @recipe_item.update(recipe_item_params)
        redirect_to admin_recipe_items_path, notice: "#{@recipe_item.menu_item.name} recipe line has been updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      menu_item_name = @recipe_item.menu_item.name
      ingredient_name = @recipe_item.ingredient.name

      if @recipe_item.destroy
        redirect_to admin_recipe_items_path, notice: "Removed #{ingredient_name} from #{menu_item_name}."
      else
        alert = "Could not remove #{ingredient_name} from #{menu_item_name}."
        alert += " #{@recipe_item.errors.full_messages.to_sentence}" if @recipe_item.errors.any?
        redirect_to admin_recipe_items_path, alert: alert
      end
    end

    private

    def set_recipe_item
      @recipe_item = RecipeItem.find(params[:id])
    end

    def set_menu_items_and_ingredients
      @menu_items = MenuItem.order(:name, :id)
      @ingredients = Ingredient.order(:name, :id)
    end

    def recipe_item_params
      params.require(:recipe_item).permit(:menu_item_id, :ingredient_id, :quantity)
    end
  end
end
