# frozen_string_literal: true

# Menu item names identify the product in a cafe catalogue, so names are
# unique across categories.  Adds a unique index to enforce this at the
# database level alongside the model validation.
#
# Verify against seeds: seed menu item names are already unique.

class AddUniqueIndexToMenuItemsName < ActiveRecord::Migration[8.1]
  def change
    add_index :menu_items, :name, unique: true, if_not_exists: true
  end
end
