class CreateRecipeItems < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_items do |t|
      t.references :menu_item, null: false, foreign_key: true, index: false
      t.references :ingredient, null: false, foreign_key: true, index: false
      t.decimal :quantity, precision: 10, scale: 3, null: false

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :recipe_items, [ :menu_item_id, :ingredient_id ], unique: true
    add_index :recipe_items, :ingredient_id
  end
end
