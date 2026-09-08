class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true, index: false
      t.references :menu_item, null: false, foreign_key: true, index: false
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      t.integer :subtotal_cents, null: false
      t.boolean :redeemed, null: false, default: false

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :order_items, :order_id
    add_index :order_items, :menu_item_id
    add_index :order_items, [ :order_id, :menu_item_id ]
  end
end
