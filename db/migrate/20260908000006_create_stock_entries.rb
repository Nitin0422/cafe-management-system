class CreateStockEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_entries do |t|
      t.references :ingredient, null: false, foreign_key: true, index: false
      t.decimal :quantity, precision: 10, scale: 3, null: false
      t.integer :entry_type, null: false
      t.string :reference
      t.text :note

      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :stock_entries, :ingredient_id
    add_index :stock_entries, :entry_type
    add_index :stock_entries, :created_at
    add_index :stock_entries, [ :ingredient_id, :created_at ]
  end
end
