# frozen_string_literal: true

require "rails_helper"

RSpec.describe PointsEntry, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:points_entry)).to be_valid
    end

    it "rejects a zero quantity" do
      points_entry = build(:points_entry, quantity: 0)
      expect(points_entry).not_to be_valid
      expect(points_entry.errors[:quantity]).to be_present
    end

    it "accepts positive (earn) and negative (redeem) quantities" do
      expect(build(:points_entry, quantity: 100)).to be_valid
      expect(build(:points_entry, quantity: -100)).to be_valid
    end

    it "rejects an unknown entry type" do
      expect { build(:points_entry, entry_type: :bogus) }.to raise_error(ArgumentError)
    end

    it "requires created_by" do
      points_entry = build(:points_entry, created_by: nil)
      expect(points_entry).not_to be_valid
      expect(points_entry.errors[:created_by]).to be_present
    end

    it "allows a nil order" do
      expect(build(:points_entry, order: nil)).to be_valid
    end
  end

  describe "enums" do
    it "maps entry types to their integer values" do
      expect(described_class.entry_types).to eq("accrual" => 0, "redemption" => 1)
    end

    it "exposes entry type predicates" do
      expect(build(:points_entry, entry_type: :accrual).accrual?).to be(true)
      expect(build(:points_entry, entry_type: :redemption).redemption?).to be(true)
    end
  end

  describe "associations" do
    it "belongs to a user" do
      expect(build(:points_entry).user).to be_a(User)
    end
  end
end
