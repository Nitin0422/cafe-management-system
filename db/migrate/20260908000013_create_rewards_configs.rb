class CreateRewardsConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :rewards_configs do |t|
      t.decimal :points_per_rupee, precision: 10, scale: 4, null: false, default: 1.0

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
