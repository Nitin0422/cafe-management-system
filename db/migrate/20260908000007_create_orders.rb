class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.integer :status, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.integer :closure_type

      t.references :customer, foreign_key: { to_table: :users }
      t.references :closed_by, foreign_key: { to_table: :users }
      t.datetime :closed_at

      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, :created_at
    add_index :orders, :closure_type
  end
end
