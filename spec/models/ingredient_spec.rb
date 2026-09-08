# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ingredient, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:ingredient)).to be_valid
    end

    it "requires a name" do
      ingredient = build(:ingredient, name: nil)
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:name]).to be_present
    end

    it "requires a unique name" do
      create(:ingredient, name: "Coffee Beans")
      ingredient = build(:ingredient, name: "Coffee Beans")
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:name]).to be_present
    end

    it "requires a unit" do
      ingredient = build(:ingredient, unit: nil)
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:unit]).to be_present
    end

    it "rejects a negative low stock threshold" do
      ingredient = build(:ingredient, low_stock_threshold: -1)
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:low_stock_threshold]).to be_present
    end

    it "allows a zero low stock threshold" do
      expect(build(:ingredient, low_stock_threshold: 0)).to be_valid
    end
  end

  describe "#current_stock" do
    it "returns the sum of all stock entries" do
      ingredient = create(:ingredient)
      create(:stock_entry, ingredient: ingredient, quantity: 100)
      create(:stock_entry, ingredient: ingredient, quantity: 50)
      create(:stock_entry, ingredient: ingredient, quantity: -25)

      expect(ingredient.current_stock).to eq(125)
    end

    it "ignores entries for other ingredients" do
      ingredient = create(:ingredient)
      other = create(:ingredient)
      create(:stock_entry, ingredient: other, quantity: 500)

      expect(ingredient.current_stock).to eq(0)
    end
  end

  describe "#low_stock?" do
    it "is true when stock is at or below the threshold" do
      ingredient = create(:ingredient, low_stock_threshold: 20)
      create(:stock_entry, ingredient: ingredient, quantity: 20)

      expect(ingredient.low_stock?).to be(true)
    end

    it "is false when stock is above the threshold" do
      ingredient = create(:ingredient, low_stock_threshold: 20)
      create(:stock_entry, ingredient: ingredient, quantity: 21)

      expect(ingredient.low_stock?).to be(false)
    end

    it "is true for a zero threshold with no stock" do
      ingredient = create(:ingredient)
      expect(ingredient.low_stock?).to be(true)
    end
  end

  describe "associations" do
    it "restricts deletion when used in a recipe" do
      ingredient = create(:ingredient)
      create(:recipe_item, ingredient: ingredient)

      expect(ingredient.destroy).to be(false)
      expect(Ingredient.exists?(ingredient.id)).to be(true)
    end

    it "destroys stock entries alongside the ingredient" do
      ingredient = create(:ingredient)
      entry = create(:stock_entry, ingredient: ingredient)
      ingredient.destroy
      expect(StockEntry.exists?(entry.id)).to be(false)
    end
  end
end
