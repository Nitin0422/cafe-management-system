class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.references :category, null: false, foreign_key: true
      t.boolean :available, null: false, default: true
      t.boolean :redeemable, null: false, default: false

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :menu_items, :available
    add_index :menu_items, [ :category_id, :available ]
  end
end
