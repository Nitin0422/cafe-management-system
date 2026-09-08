class CreateTabPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :tab_payments do |t|
      t.references :credit_account, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.integer :payment_type, null: false
      t.string :reference
      t.text :note

      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tab_payments, :created_at
  end
end
