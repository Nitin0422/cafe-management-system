# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:order)).to be_valid
    end

    it "requires a unique order_number" do
      create(:order, order_number: "ORD-ABC12345")
      duplicate = build(:order, order_number: "ORD-ABC12345")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:order_number]).to be_present
    end

    it "rejects an unknown status" do
      expect { build(:order, status: :bogus) }.to raise_error(ArgumentError)
    end

    it "allows a nil closure type" do
      expect(build(:order, closure_type: nil)).to be_valid
    end

    it "rejects an unknown closure type" do
      expect { build(:order, closure_type: :bogus) }.to raise_error(ArgumentError)
    end

    it "requires created_by" do
      order = build(:order, created_by: nil)
      expect(order).not_to be_valid
      expect(order.errors[:created_by]).to be_present
    end
  end

  describe "order number generation" do
    it "generates an ORD-<8 alphanumeric> order number on create" do
      order = create(:order)
      expect(order.order_number).to match(/\AORD-[A-Z0-9]{8}\z/)
    end

    it "does not overwrite a caller-supplied order number" do
      order = create(:order, order_number: "ORD-MYOWN123")
      expect(order.order_number).to eq("ORD-MYOWN123")
    end
  end

  describe "enums" do
    it "maps statuses to their integer values" do
      expect(described_class.statuses).to eq("draft" => 0, "open" => 1, "closed" => 2, "cancelled" => 3)
    end

    it "maps closure types with a prefix" do
      expect(described_class.closure_types).to eq("cash" => 0, "card" => 1, "tab" => 2, "other" => 3)
    end

    it "exposes prefixed closure type predicates" do
      order = build(:order, closure_type: :tab)
      expect(order.closure_type_tab?).to be(true)
      expect(order.closure_type_cash?).to be(false)
    end
  end

  describe "associations" do
    it "destroys order items, payments, and points entries alongside the order" do
      order = create(:order)
      order_item = create(:order_item, order: order)
      payment = create(:payment, order: order)
      point = create(:points_entry, order: order, user: order.customer)

      order.destroy

      expect(OrderItem.exists?(order_item.id)).to be(false)
      expect(Payment.exists?(payment.id)).to be(false)
      expect(PointsEntry.exists?(point.id)).to be(false)
    end

    it "belongs to a customer and a created_by user" do
      customer = create(:user)
      created_by = create(:user, :staff)
      order = create(:order, customer: customer, created_by: created_by)

      expect(order.customer).to eq(customer)
      expect(order.created_by).to eq(created_by)
    end
  end
end
