# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:user)).to be_valid
    end

    it "requires an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "requires a valid email format" do
      user = build(:user, email: "not-an-email")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "requires a unique email" do
      create(:user, email: "duplicate@example.com")
      user = build(:user, email: "duplicate@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "requires a full name" do
      user = build(:user, full_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:full_name]).to be_present
    end

    it "requires a unique phone when present" do
      create(:user, phone: "+977-9800000001")
      user = build(:user, phone: "+977-9800000001")
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to be_present
    end

    it "allows a nil phone" do
      expect(build(:user, phone: nil)).to be_valid
    end

    it "rejects an unknown role" do
      expect { build(:user, role: :bogus) }.to raise_error(ArgumentError)
    end
  end

  describe "email normalization" do
    it "downcases and strips the email before validation" do
      user = create(:user, email: "  John@Example.COM ")

      expect(user.email).to eq("john@example.com")
    end

    it "catches duplicates that differ only by case and whitespace" do
      create(:user, email: "john@example.com")
      user = build(:user, email: " John@Example.COM ")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "enums" do
    it "maps roles to their integer values" do
      expect(described_class.roles).to eq("admin" => 0, "staff" => 1, "customer" => 2)
    end

    it "exposes role predicates" do
      expect(build(:user, :admin).admin?).to be(true)
      expect(build(:user, role: :staff).staff?).to be(true)
      expect(build(:user).customer?).to be(true)
    end
  end

  describe "attribution" do
    it "stamps created_by and updated_by from Current.user on create" do
      actor = create(:user, :admin)
      Current.user = actor

      user = create(:user, :staff, created_by: nil)
      expect(user.created_by).to eq(actor)
      expect(user.updated_by).to eq(actor)
    end
  end

  describe "employees scope" do
    it "returns admins and staff but excludes customers" do
      admin = create(:user, :admin)
      staff = create(:user, :staff)
      customer = create(:user, :customer)

      expect(User.employees).to contain_exactly(admin, staff)
      expect(User.employees).not_to include(customer)
    end
  end

  describe "active flag" do
    it "defaults to true" do
      expect(build(:user).active).to be(true)
    end
  end

  describe "secure password" do
    it "authenticates with the correct password" do
      user = build(:user, password: "secret123")
      expect(user.authenticate("secret123")).to eq(user)
      expect(user.authenticate("wrong-password")).to be(false)
    end
  end

  describe "associations" do
    it "destroys the credit account alongside the user" do
      user = create(:user)
      account = create(:credit_account, user: user)
      user.destroy
      expect(CreditAccount.exists?(account.id)).to be(false)
    end

    it "destroys points entries alongside the user" do
      user = create(:user)
      entry = create(:points_entry, user: user)
      user.destroy
      expect(PointsEntry.exists?(entry.id)).to be(false)
    end

    it "prevents destroying a user who has created orders" do
      user = create(:user)
      create(:order, created_by: user)

      expect(user.destroy).to be(false)
      expect(user).to be_persisted
    end
  end
end
