# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:category)).to be_valid
    end

    it "requires a name" do
      category = build(:category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to be_present
    end

    it "requires a unique name" do
      create(:category, name: "Beverages")
      category = build(:category, name: "Beverages")
      expect(category).not_to be_valid
      expect(category.errors[:name]).to be_present
    end
  end

  describe "associations" do
    it "restricts deletion when menu items exist" do
      category = create(:category)
      create(:menu_item, category: category)

      expect(category.destroy).to be(false)
      expect(category.errors[:base]).to be_present
      expect(Category.exists?(category.id)).to be(true)
    end
  end
end
