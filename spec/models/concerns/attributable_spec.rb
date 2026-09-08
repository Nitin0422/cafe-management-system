# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attributable, type: :model do
  describe "attribution stamping" do
    around(:each) do |example|
      actor = create(:user, :staff)
      Current.user = actor
      example.run
      Current.reset
    end

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
    it "requires created_by on orders" do
      expect(build(:order, created_by: nil)).not_to be_valid
    end

    it "requires created_by on payments" do
      expect(build(:payment, created_by: nil)).not_to be_valid
    end

    it "requires created_by on stock entries" do
      expect(build(:stock_entry, created_by: nil)).not_to be_valid
    end

    it "requires created_by on tab payments" do
      expect(build(:tab_payment, created_by: nil)).not_to be_valid
    end

    it "requires created_by on points entries" do
      expect(build(:points_entry, created_by: nil)).not_to be_valid
    end
  end
end
