class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.string :unit, null: false
      t.decimal :low_stock_threshold, precision: 10, scale: 3, null: false, default: 0

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
  end
end
