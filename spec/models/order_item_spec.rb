# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:order_item)).to be_valid
    end

    it "requires a quantity of at least one" do
      expect(build(:order_item, quantity: 0)).not_to be_valid
      expect(build(:order_item, quantity: -1)).not_to be_valid
      expect(build(:order_item, quantity: 1)).to be_valid
    end

    it "rejects negative unit prices" do
      order_item = build(:order_item, unit_price_cents: -1)
      expect(order_item).not_to be_valid
      expect(order_item.errors[:unit_price_cents]).to be_present
    end

    it "rejects negative subtotals" do
      order_item = build(:order_item, subtotal_cents: -1)
      expect(order_item).not_to be_valid
      expect(order_item.errors[:subtotal_cents]).to be_present
    end

    it "allows a zero price for redeemed items" do
      expect(build(:order_item, unit_price_cents: 0, subtotal_cents: 0, redeemed: true)).to be_valid
    end
  end

  describe "associations" do
    it "belongs to an order and a menu item" do
      order_item = create(:order_item)
      expect(order_item.order).to be_a(Order)
      expect(order_item.menu_item).to be_a(MenuItem)
    end
  end
end
