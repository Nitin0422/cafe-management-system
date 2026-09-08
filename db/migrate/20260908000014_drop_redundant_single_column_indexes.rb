# frozen_string_literal: true

# Drop three redundant single-column indexes whose leading column is already
# the leading column of an existing composite index.  Keeping them only adds
# write overhead with no additional read benefit.
#
# Dropped:
#   index_order_items_on_order_id      — redundant with [order_id, menu_item_id]
#   index_stock_entries_on_ingredient_id — redundant with [ingredient_id, created_at]
#   index_points_entries_on_user_id     — redundant with [user_id, created_at]

class DropRedundantSingleColumnIndexes < ActiveRecord::Migration[8.1]
  def change
    remove_index :order_items, column: :order_id, if_exists: true
    remove_index :stock_entries, column: :ingredient_id, if_exists: true
    remove_index :points_entries, column: :user_id, if_exists: true
  end
end
