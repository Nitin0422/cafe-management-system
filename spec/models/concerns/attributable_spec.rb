# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attributable, type: :model do
  # Sets an acting user for every example and resets it afterwards, so both the
  # nil-actor and positive-actor stamping paths can be exercised.
  around(:each) do |example|
    actor = create(:user, :staff)
    Current.user = actor
    example.run
    Current.reset
  end

  describe "attribution stamping" do
    it "stamps created_by and updated_by from Current.user on create" do
      category = create(:category)
      expect(category.created_by).to eq(Current.user)
      expect(category.updated_by).to eq(Current.user)
    end

    it "updates updated_by, but not created_by, on update" do
      category = create(:category)
      original_creator = category.created_by

      other_actor = create(:user, :admin)
      Current.user = other_actor
      category.update!(name: "Renamed")

      expect(category.updated_by).to eq(other_actor)
      expect(category.created_by).to eq(original_creator)
    end

    it "does not overwrite an explicitly supplied created_by" do
      explicit = create(:user, :admin)
      category = create(:category, created_by: explicit)
      expect(category.created_by).to eq(explicit)
    end

    it "leaves attribution nil when Current.user is not set" do
      Current.reset
      category = create(:category)
      expect(category.created_by).to be_nil
      expect(category.updated_by).to be_nil
    end
  end

  describe "mandatory attribution (FR-12)" do
    # These build-based tests assert that a record lacking explicit attribution
    # is rejected.  Run with no Current.user so before_validation cannot stamp
    # one in; this verifies the model requires an explicit/current actor.
    before(:each) { Current.reset }

    it "requires created_by on orders" do
      order = build(:order, created_by: nil)
      expect(order).not_to be_valid
      expect(order.errors[:created_by]).to be_present
    end

    it "requires created_by on payments" do
      payment = build(:payment, created_by: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:created_by]).to be_present
    end

    it "requires created_by on stock entries" do
      entry = build(:stock_entry, created_by: nil)
      expect(entry).not_to be_valid
      expect(entry.errors[:created_by]).to be_present
    end

    it "requires created_by on tab payments" do
      tab = build(:tab_payment, created_by: nil)
      expect(tab).not_to be_valid
      expect(tab.errors[:created_by]).to be_present
    end

    it "requires created_by on points entries" do
      points = build(:points_entry, created_by: nil)
      expect(points).not_to be_valid
      expect(points.errors[:created_by]).to be_present
    end
  end

  describe "positive stamping for mandatory-attribution models" do
    # The top-level around hook sets Current.user, so these create/update
    # assertions exercise stamping with an actor present.  The factories
    # default `created_by` to an explicit user, so we pass `created_by: nil`
    # to let the Attributable concern stamp Current.user instead.

    it "stamps created_by/updated_by on order create and updated_by on save" do
      actor = Current.user
      order = create(:order, created_by: nil)
      expect(order.created_by).to eq(actor)
      expect(order.updated_by).to eq(actor)

      other = create(:user, :admin)
      Current.user = other
      order.update!(status: :cancelled)
      expect(order.updated_by).to eq(other)
      expect(order.created_by).to eq(actor)
    end

    it "stamps created_by/updated_by on payment create and updated_by on save" do
      actor = Current.user
      payment = create(:payment, created_by: nil)
      expect(payment.created_by).to eq(actor)
      expect(payment.updated_by).to eq(actor)

      other = create(:user, :admin)
      Current.user = other
      payment.update!(reference: "REF-1")
      expect(payment.updated_by).to eq(other)
      expect(payment.created_by).to eq(actor)
    end

    it "stamps created_by/updated_by on stock entry create and updated_by on save" do
      actor = Current.user
      entry = create(:stock_entry, created_by: nil)
      expect(entry.created_by).to eq(actor)
      expect(entry.updated_by).to eq(actor)

      other = create(:user, :admin)
      Current.user = other
      entry.update!(quantity: 250)
      expect(entry.updated_by).to eq(other)
      expect(entry.created_by).to eq(actor)
    end

    it "stamps created_by/updated_by on tab payment create and updated_by on save" do
      actor = Current.user
      tab = create(:tab_payment, created_by: nil)
      expect(tab.created_by).to eq(actor)
      expect(tab.updated_by).to eq(actor)

      other = create(:user, :admin)
      Current.user = other
      tab.update!(reference: "TAB-9")
      expect(tab.updated_by).to eq(other)
      expect(tab.created_by).to eq(actor)
    end

    it "stamps created_by/updated_by on points entry create and updated_by on save" do
      actor = Current.user
      points = create(:points_entry, created_by: nil)
      expect(points.created_by).to eq(actor)
      expect(points.updated_by).to eq(actor)

      other = create(:user, :admin)
      Current.user = other
      points.update!(description: "updated")
      expect(points.updated_by).to eq(other)
      expect(points.created_by).to eq(actor)
    end
  end
end
