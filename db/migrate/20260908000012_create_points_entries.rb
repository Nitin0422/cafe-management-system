class CreatePointsEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :points_entries do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.integer :quantity, null: false
      t.integer :entry_type, null: false
      t.references :order, foreign_key: true, index: false
      t.string :description

      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :points_entries, :user_id
    add_index :points_entries, :entry_type
    add_index :points_entries, :order_id
    add_index :points_entries, :created_at
    add_index :points_entries, [ :user_id, :created_at ]
  end
end
