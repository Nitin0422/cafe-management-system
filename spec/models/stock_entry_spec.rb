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

    it "accepts positive (add) and negative (remove) quantities" do
      expect(build(:stock_entry, quantity: 10)).to be_valid
      expect(build(:stock_entry, quantity: -10)).to be_valid
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
end
