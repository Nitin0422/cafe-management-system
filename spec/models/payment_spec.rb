# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:payment)).to be_valid
    end

    it "requires a positive amount" do
      expect(build(:payment, amount_cents: 0)).not_to be_valid
      expect(build(:payment, amount_cents: -100)).not_to be_valid
    end

    it "rejects an unknown payment type" do
      expect { build(:payment, payment_type: :bogus) }.to raise_error(ArgumentError)
    end

    it "requires created_by" do
      payment = build(:payment, created_by: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:created_by]).to be_present
    end
  end

  describe "enums" do
    it "maps payment types to their integer values" do
      expect(described_class.payment_types).to eq("cash" => 0, "card" => 1, "other" => 2)
    end

    it "exposes payment type predicates" do
      expect(build(:payment, payment_type: :cash).cash?).to be(true)
      expect(build(:payment, payment_type: :card).card?).to be(true)
      expect(build(:payment, payment_type: :other).other?).to be(true)
    end
  end

  describe "associations" do
    it "belongs to an order" do
      expect(build(:payment).order).to be_a(Order)
    end
  end
end
