# frozen_string_literal: true

require "rails_helper"

RSpec.describe RewardsConfig, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:rewards_config)).to be_valid
    end

    it "rejects a negative points per rupee" do
      config = build(:rewards_config, points_per_rupee: -0.1)
      expect(config).not_to be_valid
      expect(config.errors[:points_per_rupee]).to be_present
    end

    it "allows a zero points per rupee" do
      expect(build(:rewards_config, points_per_rupee: 0)).to be_valid
    end
  end

  describe "singleton" do
    it "allows the first configuration" do
      expect(create(:rewards_config)).to be_persisted
    end

    it "rejects a second configuration" do
      create(:rewards_config)

      duplicate = build(:rewards_config)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:base]).to be_present
    end

    it "allows updating the existing configuration" do
      config = create(:rewards_config, points_per_rupee: 0.1)
      expect(config.update(points_per_rupee: 0.2)).to be(true)
      expect(config.reload.points_per_rupee).to eq(0.2)
    end

    it "allows creating a new configuration after deleting the old one" do
      create(:rewards_config)
      RewardsConfig.delete_all

      expect(build(:rewards_config)).to be_valid
    end
  end
end
