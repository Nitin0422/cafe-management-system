class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :phone
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.string :full_name, null: false
      t.boolean :active, null: false, default: true

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true, where: "phone IS NOT NULL"
    add_index :users, :role
    add_index :users, :active
  end
end
