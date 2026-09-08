# Idempotent seed data for the Aafnai Coffee domain (T2).
# Safe to run repeatedly: every record is created via find_or_create_by!.
#
# NOTE: find_or_create_by! only fills the block-supplied attributes when it
# CREATES a new row. If a row already exists (matched on the identifying
# columns such as email/name), value edits in the block are NOT propagated.
# To change a value for an existing row, update the record explicitly or
# delete the row and re-seed.

# --- Users ---

admin = User.find_or_create_by!(email: "admin@aafnaicoffee.com") do |user|
  user.full_name = "Aafnai Admin"
  user.phone = "+977-9810000000"
  user.role = :admin
  user.password = "password123"
end

[
  { email: "sita@aafnaicoffee.com", full_name: "Sita Rai", phone: "+977-9810000001" },
  { email: "ram@aafnaicoffee.com", full_name: "Ram Shrestha", phone: "+977-9810000002" }
].each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.full_name = attrs[:full_name]
    user.phone = attrs[:phone]
    user.role = :staff
    user.password = "password123"
  end
end

customer_users = [
  { email: "anisha@example.com", full_name: "Anisha Gurung", phone: "+977-9810000010" },
  { email: "bibek@example.com", full_name: "Bibek Tamang", phone: "+977-9810000011" }
].map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.full_name = attrs[:full_name]
    user.phone = attrs[:phone]
    user.role = :customer
    user.password = "password123"
  end
end

# --- Credit accounts (one active account per customer, balance 0) ---

customer_users.each do |customer|
  CreditAccount.find_or_create_by!(user: customer) do |account|
    account.balance_cents = 0
    account.status = :active
  end
end

# --- Catalog and reference data, attributed to admin ---
#
# Wrapping the catalog/seed row creation in Current.set(user: admin) lets the
# Attributable concern stamp created_by/updated_by on every attributed row,
# so seed catalog data carries explicit attribution instead of NULL.
Current.set(user: admin) do
  # --- Categories ---

  categories = %w[Coffee Tea Snacks].map do |name|
    Category.find_or_create_by!(name: name)
  end
  coffee = categories[0]
  tea = categories[1]
  snacks = categories[2]

  # --- Ingredients ---

  ingredients = {
    "Coffee Beans" => [ "g", 500 ],
    "Milk" => [ "ml", 1000 ],
    "Sugar" => [ "g", 500 ],
    "Tea Leaves" => [ "g", 200 ],
    "Flour" => [ "g", 1000 ],
    "Potatoes" => [ "g", 2000 ],
    "Cooking Oil" => [ "ml", 1000 ]
  }.map do |name, (unit, threshold)|
    Ingredient.find_or_create_by!(name: name) do |ingredient|
      ingredient.unit = unit
      ingredient.low_stock_threshold = threshold
    end
  end

  coffee_beans, milk, sugar, tea_leaves, flour, potatoes, cooking_oil = ingredients

  # --- Menu items (prices in paisa: 150.00 NPR = 15_000) ---

  menu_items = {
    "Black Coffee" => { category: coffee, price_cents: 15_000, redeemable: false },
    "Milk Coffee" => { category: coffee, price_cents: 18_000, redeemable: true },
    "Milk Tea" => { category: tea, price_cents: 12_000, redeemable: true },
    "Veg Mo:Mo" => { category: snacks, price_cents: 25_000, redeemable: false }
  }.map do |name, attrs|
    MenuItem.find_or_create_by!(name: name) do |item|
      item.category = attrs[:category]
      item.description = "#{name} - fresh from the Aafnai counter."
      item.price_cents = attrs[:price_cents]
      item.redeemable = attrs[:redeemable]
    end
  end

  black_coffee, milk_coffee, milk_tea, veg_momo = menu_items

  # --- Recipe items (ingredient quantities per menu item) ---

  recipe_defs = {
    black_coffee => { coffee_beans => 15, sugar => 5 },
    milk_coffee => { coffee_beans => 15, milk => 150, sugar => 5 },
    milk_tea => { tea_leaves => 5, milk => 100, sugar => 5 },
    veg_momo => { flour => 100, potatoes => 80, cooking_oil => 10 }
  }

  recipe_defs.each do |menu_item, specs|
    specs.each do |ingredient, quantity|
      RecipeItem.find_or_create_by!(menu_item: menu_item, ingredient: ingredient) do |recipe_item|
        recipe_item.quantity = quantity
      end
    end
  end

  # --- Initial stock (restock entries, attributed to admin) ---

  initial_stock = {
    coffee_beans => 5_000,
    milk => 20_000,
    sugar => 5_000,
    tea_leaves => 2_000,
    flour => 5_000,
    potatoes => 10_000,
    cooking_oil => 5_000
  }

  initial_stock.each do |ingredient, quantity|
    reference = "initial-stock"
    StockEntry.find_or_create_by!(ingredient: ingredient, entry_type: :restock, reference: reference) do |entry|
      entry.quantity = quantity
      entry.note = "Initial stock on setup (seed)."
      entry.created_by = admin
    end
  end

  # --- Rewards configuration (singleton) ---

  RewardsConfig.find_or_create_by!(id: 1) do |config|
    config.points_per_rupee = 0.1
  end
end
