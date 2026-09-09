# frozen_string_literal: true

require "rails_helper"

RSpec.describe StockEntry, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:stock_entry)).to be_valid
    end

    it "rejects a zero quantity" do
      stock_entry = build(:stock_entry, quantity: 0)
      expect(stock_entry).not_to be_valid
      expect(stock_entry.errors[:quantity]).to be_present
    end

    it "accepts a positive restock quantity" do
      expect(build(:stock_entry, quantity: 10, entry_type: :restock)).to be_valid
    end

    it "accepts positive and negative correction quantities" do
      expect(build(:stock_entry, quantity: 10, entry_type: :correction)).to be_valid
      expect(build(:stock_entry, quantity: -10, entry_type: :correction)).to be_valid
    end

    it "rejects a negative quantity for a restock" do
      stock_entry = build(:stock_entry, quantity: -10, entry_type: :restock)
      expect(stock_entry).not_to be_valid
      expect(stock_entry.errors[:quantity]).to be_present
    end

    it "rejects a zero quantity for a restock" do
      stock_entry = build(:stock_entry, quantity: 0, entry_type: :restock)
      expect(stock_entry).not_to be_valid
      expect(stock_entry.errors[:quantity]).to be_present
    end

    it "allows a negative quantity for a correction" do
      expect(build(:stock_entry, quantity: -10, entry_type: :correction)).to be_valid
    end

    it "rejects an unknown entry type" do
      expect { build(:stock_entry, entry_type: :bogus) }.to raise_error(ArgumentError)
    end

    it "requires created_by" do
      stock_entry = build(:stock_entry, created_by: nil)
      expect(stock_entry).not_to be_valid
      expect(stock_entry.errors[:created_by]).to be_present
    end
  end

  describe "enums" do
    it "maps entry types to their integer values" do
      expect(described_class.entry_types).to eq("restock" => 0, "correction" => 1, "sale_decrement" => 2)
    end

    it "exposes entry type predicates" do
      expect(build(:stock_entry, entry_type: :restock).restock?).to be(true)
      expect(build(:stock_entry, entry_type: :correction).correction?).to be(true)
      expect(build(:stock_entry, entry_type: :sale_decrement).sale_decrement?).to be(true)
    end
  end

  describe "associations" do
    it "belongs to an ingredient" do
      expect(build(:stock_entry).ingredient).to be_a(Ingredient)
    end
  end

  describe ".decrement_for_sale!" do
    let(:seller) { create(:user, :staff) }

    it "creates sale_decrement entries for each recipe ingredient by recipe quantity" do
      Current.user = seller
      menu_item = create(:menu_item, name: "Latte")
      beans = create(:ingredient, name: "Coffee Beans", unit: "g")
      milk = create(:ingredient, name: "Milk", unit: "ml")

      create(:recipe_item, menu_item: menu_item, ingredient: beans, quantity: "18")
      create(:recipe_item, menu_item: menu_item, ingredient: milk, quantity: "150")

      expect do
        StockEntry.decrement_for_sale!(menu_item: menu_item)
      end.to change(StockEntry, :count).by(2)

      beans_entry = StockEntry.find_by(ingredient: beans, entry_type: :sale_decrement)
      milk_entry = StockEntry.find_by(ingredient: milk, entry_type: :sale_decrement)
      expect(beans_entry.quantity).to eq(-18)
      expect(milk_entry.quantity).to eq(-150)
      expect(beans_entry.created_by).to eq(seller)
      expect(milk_entry.created_by).to eq(seller)
    end

    it "scales the decrement by the number of units sold" do
      Current.user = seller
      menu_item = create(:menu_item, name: "Flat White")
      coffee = create(:ingredient, name: "Coffee", unit: "g")
      create(:recipe_item, menu_item: menu_item, ingredient: coffee, quantity: "20")

      expect do
        StockEntry.decrement_for_sale!(menu_item: menu_item, quantity: 3)
      end.to change(StockEntry, :count).by(1)

      expect(StockEntry.last.quantity).to eq(-60)
    end

    it "decrements each ingredient's cumulative stock by the recipe quantity" do
      Current.user = seller
      menu_item = create(:menu_item, name: "Espresso")
      beans = create(:ingredient, name: "Whole Beans", unit: "g")
      create(:recipe_item, menu_item: menu_item, ingredient: beans, quantity: "9")
      create(:stock_entry, ingredient: beans, quantity: 100, created_by: seller)

      StockEntry.decrement_for_sale!(menu_item: menu_item)

      expect(beans.reload.current_stock).to eq(91)
    end

    it "records no entries for a menu item without a recipe" do
      Current.user = seller
      menu_item = create(:menu_item, name: "Unsold Item")

      expect do
        StockEntry.decrement_for_sale!(menu_item: menu_item)
      end.not_to change(StockEntry, :count)
    end

    it "raises when created_by is missing (no actor)" do
      # Current.user is not set, so the attribution concern cannot stamp
      # created_by and the required presence validation fails.
      menu_item = create(:menu_item, name: "Cappuccino")
      beans = create(:ingredient, name: "Roasted Beans", unit: "g")
      create(:recipe_item, menu_item: menu_item, ingredient: beans, quantity: "12")

      expect { StockEntry.decrement_for_sale!(menu_item: menu_item) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
