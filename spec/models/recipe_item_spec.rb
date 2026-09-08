# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecipeItem, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:recipe_item)).to be_valid
    end

    it "rejects a non-positive quantity" do
      expect(build(:recipe_item, quantity: 0)).not_to be_valid
      expect(build(:recipe_item, quantity: -1)).not_to be_valid
    end

    it "enforces uniqueness of the menu item / ingredient pair" do
      menu_item = create(:menu_item)
      ingredient = create(:ingredient)
      create(:recipe_item, menu_item: menu_item, ingredient: ingredient)

      duplicate = build(:recipe_item, menu_item: menu_item, ingredient: ingredient)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:menu_item_id]).to be_present
    end

    it "allows the same ingredient in different menu items" do
      ingredient = create(:ingredient)
      create(:recipe_item, ingredient: ingredient)

      other = build(:recipe_item, ingredient: ingredient)
      expect(other).to be_valid
    end

    it "allows the same menu item with different ingredients" do
      menu_item = create(:menu_item)
      create(:recipe_item, menu_item: menu_item)

      other = build(:recipe_item, menu_item: menu_item)
      expect(other).to be_valid
    end
  end

  describe "associations" do
    it "belongs to a menu item and an ingredient" do
      recipe_item = create(:recipe_item)
      expect(recipe_item.menu_item).to be_a(MenuItem)
      expect(recipe_item.ingredient).to be_a(Ingredient)
    end
  end
end
