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

    it "requires a phone for customers" do
      user = build(:user, :customer, phone: nil)
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to be_present
    end

    it "allows a nil phone for employees" do
      expect(build(:user, :staff, phone: nil)).to be_valid
      expect(build(:user, :admin, phone: nil)).to be_valid
    end

    it "rejects a phone with an invalid format" do
      user = build(:user, phone: "not-a-phone")
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to be_present
    end

    it "rejects a phone that is too short" do
      user = build(:user, phone: "123456")
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to be_present
    end

    it "rejects a phone that is too long" do
      user = build(:user, phone: "+977-9" + "0" * 20)
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to be_present
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

  describe "phone normalization" do
    it "strips surrounding whitespace before validation" do
      user = create(:user, phone: "  +977-9800000001  ")

      expect(user.phone).to eq("+977-9800000001")
    end
  end

  describe ".find_by_identifier" do
    it "finds a user by email, case-insensitively and ignoring whitespace" do
      user = create(:user, email: "john@example.com")

      expect(described_class.find_by_identifier("  JOHN@Example.COM ")).to eq(user)
    end

    it "finds a user by phone, ignoring surrounding whitespace" do
      user = create(:user, phone: "+977-9800000001")

      expect(described_class.find_by_identifier("  +977-9800000001  ")).to eq(user)
    end

    it "returns nil when no user matches" do
      expect(described_class.find_by_identifier("nobody@example.com")).to be_nil
    end

    it "returns nil for a blank identifier" do
      expect(described_class.find_by_identifier("  ")).to be_nil
    end
  end

  describe ".authenticate_identifier" do
    let(:user) { create(:user, :customer, email: "cust@example.com", phone: "+977-9800000001") }

    it "returns the user with a matching email and password" do
      expect(described_class.authenticate_identifier(user.email, "password123")).to eq(user)
    end

    it "returns the user with a matching phone and password" do
      expect(described_class.authenticate_identifier(user.phone, "password123")).to eq(user)
    end

    it "returns nil with a wrong password" do
      expect(described_class.authenticate_identifier(user.email, "wrong-password")).to be_nil
    end

    it "returns nil with an unknown identifier" do
      expect(described_class.authenticate_identifier("nobody@example.com", "password123")).to be_nil
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
