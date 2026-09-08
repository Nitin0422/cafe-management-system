# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuItem, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:menu_item)).to be_valid
    end

    it "requires a name" do
      menu_item = build(:menu_item, name: nil)
      expect(menu_item).not_to be_valid
      expect(menu_item.errors[:name]).to be_present
    end

    it "requires a positive price" do
      expect(build(:menu_item, price_cents: 0)).not_to be_valid
      expect(build(:menu_item, price_cents: -100)).not_to be_valid
    end

    it "requires a category" do
      menu_item = build(:menu_item, category: nil)
      expect(menu_item).not_to be_valid
      expect(menu_item.errors[:category]).to be_present
    end

    it "is valid with an integer price in paisa" do
      expect(build(:menu_item, price_cents: 15_000)).to be_valid
    end
  end

  describe "associations" do
    it "destroys recipe items alongside the menu item" do
      menu_item = create(:menu_item)
      recipe_item = create(:recipe_item, menu_item: menu_item)
      menu_item.destroy
      expect(RecipeItem.exists?(recipe_item.id)).to be(false)
    end

    it "exposes ingredients through recipe items" do
      menu_item = create(:menu_item)
      ingredient = create(:ingredient)
      create(:recipe_item, menu_item: menu_item, ingredient: ingredient)

      expect(menu_item.ingredients).to contain_exactly(ingredient)
    end

    it "restricts deletion when referenced by an order item" do
      menu_item = create(:menu_item)
      create(:order_item, menu_item: menu_item)

      expect(menu_item.destroy).to be(false)
      expect(MenuItem.exists?(menu_item.id)).to be(true)
    end
  end
end
