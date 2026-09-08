class CreateCreditAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_accounts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :balance_cents, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :credit_accounts, :status
  end
end
