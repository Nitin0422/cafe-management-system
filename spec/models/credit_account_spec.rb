# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreditAccount, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:credit_account)).to be_valid
    end

    it "requires a user" do
      account = build(:credit_account, user: nil)
      expect(account).not_to be_valid
      expect(account.errors[:user]).to be_present
    end

    it "enforces one credit account per user" do
      user = create(:user)
      create(:credit_account, user: user)

      duplicate = build(:credit_account, user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "rejects an unknown status" do
      expect { build(:credit_account, status: :bogus) }.to raise_error(ArgumentError)
    end
  end

  describe "enums" do
    it "maps statuses to their integer values" do
      expect(described_class.statuses).to eq("active" => 0, "suspended" => 1)
    end

    it "exposes status predicates" do
      expect(build(:credit_account, status: :active).active?).to be(true)
      expect(build(:credit_account, status: :suspended).suspended?).to be(true)
    end
  end

  describe "#outstanding_balance" do
    it "returns closed tab charges minus tab payments" do
      customer = create(:user)
      account = create(:credit_account, user: customer)
      closed_by = create(:user, :staff)
      closed_at = Time.current

      create(:order, customer: customer, status: :closed, closure_type: :tab, closed_by: closed_by, closed_at: closed_at, total_cents: 5_000)
      create(:order, customer: customer, status: :closed, closure_type: :tab, closed_by: closed_by, closed_at: closed_at, total_cents: 1_500)
      create(:tab_payment, credit_account: account, amount_cents: 2_000)

      expect(account.outstanding_balance).to eq(4_500)
    end

    it "ignores non-closed and non-tab orders" do
      customer = create(:user)
      account = create(:credit_account, user: customer)

      create(:order, customer: customer, status: :open, closure_type: :tab, total_cents: 9_000)
      create(:order, customer: customer, status: :closed, closure_type: :cash, closed_by: create(:user, :staff), closed_at: Time.current, total_cents: 8_000)

      expect(account.outstanding_balance).to eq(0)
    end
  end

  describe "associations" do
    it "destroys tab payments alongside the account" do
      account = create(:credit_account)
      payment = create(:tab_payment, credit_account: account)
      account.destroy
      expect(TabPayment.exists?(payment.id)).to be(false)
    end
  end
end
