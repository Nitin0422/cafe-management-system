require "rails_helper"

RSpec.describe "Inventory management", type: :system do
  it "lets an admin manage ingredients, recipes, and stock as an end-to-end flow" do
    coffee = create(:category, name: "Coffee")
    create(:menu_item, name: "Latte", category: coffee, price_cents: 25_000)
    admin = create(:user, :admin, full_name: "Admin One")
    visit login_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Admin One.")

    # --- Ingredients ---
    click_link "Manage ingredients"
    expect(page).to have_text("Ingredients")

    click_link "New ingredient"
    fill_in "Name", with: "Milk"
    fill_in "Unit", with: "ml"
    fill_in "Low-stock threshold", with: "500"
    click_button "Create ingredient"

    expect(page).to have_text("Ingredient created: Milk.")
    expect(page).to have_text("Milk")
    expect(page).to have_text("ml")
    expect(page).to have_text("Low stock")

    # --- Recipes ---
    visit root_path
    click_link "Manage recipes"
    expect(page).to have_text("Recipes")

    click_link "Add recipe line"
    select "Latte", from: "Menu item"
    select "Milk", from: "Ingredient"
    fill_in "Quantity", with: "150"
    click_button "Add recipe line"

    expect(page).to have_text("Latte")
    expect(page).to have_text("Milk")
    expect(page).to have_text("150.0 ml")

    # --- Stock (restock) ---
    visit root_path
    click_link "Stock entries"
    expect(page).to have_text("Stock entries")

    click_link "Record stock entry"
    select "Milk", from: "Ingredient"
    select "Restock / purchase", from: "Type"
    fill_in "Quantity", with: "1000"
    click_button "Record stock entry"

    expect(page).to have_text("Stock entry recorded for Milk.")
    expect(page).to have_text("Restock")

    # Milk is now above its threshold, so it is no longer low stock.
    visit admin_ingredients_path
    expect(page).to have_text("OK")
  end

  it "lets staff record a stock correction" do
    create(:ingredient, name: "Sugar", unit: "kg")
    staff = create(:user, :staff, full_name: "Staff One")
    visit login_path

    fill_in "Email", with: staff.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Staff One.")

    click_link "Stock entries"
    expect(page).to have_text("Stock entries")

    click_link "Record stock entry"
    select "Sugar", from: "Ingredient"
    select "Stock correction", from: "Type"
    fill_in "Quantity", with: "-5"
    click_button "Record stock entry"

    expect(page).to have_text("Stock entry recorded for Sugar.")
    expect(page).to have_text("Correction")
  end

  it "does not expose admin-only inventory pages to staff" do
    staff = create(:user, :staff, full_name: "Staff One")
    visit login_path

    fill_in "Email", with: staff.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Staff One.")
    expect(page).not_to have_link("Manage ingredients")
    expect(page).not_to have_link("Manage recipes")

    visit admin_ingredients_path
    expect(page).not_to have_text("Ingredients")

    visit admin_recipe_items_path
    expect(page).not_to have_text("Recipes")
  end
end
