# frozen_string_literal: true

require "rails_helper"

RSpec.describe TabPayment, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:tab_payment)).to be_valid
    end

    it "requires a positive amount" do
      expect(build(:tab_payment, amount_cents: 0)).not_to be_valid
      expect(build(:tab_payment, amount_cents: -100)).not_to be_valid
    end

    it "rejects an unknown payment type" do
      expect { build(:tab_payment, payment_type: :bogus) }.to raise_error(ArgumentError)
    end

    it "requires created_by" do
      payment = build(:tab_payment, created_by: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:created_by]).to be_present
    end
  end

  describe "enums" do
    it "maps payment types to their integer values" do
      expect(described_class.payment_types).to eq("cash" => 0, "card" => 1, "other" => 2)
    end
  end

  describe "associations" do
    it "belongs to a credit account" do
      expect(build(:tab_payment).credit_account).to be_a(CreditAccount)
    end
  end
end
