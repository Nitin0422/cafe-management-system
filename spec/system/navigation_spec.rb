require "rails_helper"

# The site header is the role-based navigation surface (T17). Link labels are
# contract-relevant — each role must see exactly its own entry points and
# never another role's wording.
RSpec.describe "Site header navigation", type: :system do
  it "shows guests the customer and employee login entry points only" do
    visit root_path

    expect(page).to have_link("Customer log in", href: customer_login_path)
    expect(page).to have_link("Register", href: register_path)
    expect(page).to have_link("Log in", href: login_path)

    expect(page).not_to have_button("Log out")
    expect(page).not_to have_link("Manage staff accounts")
    expect(page).not_to have_link("Manage menu")
    expect(page).not_to have_link("Manage ingredients")
    expect(page).not_to have_link("Manage recipes")
  end

  it "shows logged-in customers only the logout action" do
    customer = create(:user, :customer, full_name: "Customer Nav")
    visit customer_login_path

    fill_in "Email or phone", with: customer.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_button("Log out")
    expect(page).not_to have_link("Manage staff accounts")
    expect(page).not_to have_link("Manage menu")
    expect(page).not_to have_link("Manage ingredients")
    expect(page).not_to have_link("Manage recipes")
  end

  it "shows staff the stock and customer registration links and never admin links" do
    staff = create(:user, :staff, full_name: "Staff Nav")
    visit login_path

    fill_in "Email", with: staff.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_link("Stock entries", href: admin_stock_entries_path)
    expect(page).to have_link("Register customer", href: new_staff_customer_path)
    expect(page).to have_button("Log out")

    expect(page).not_to have_link("Manage staff accounts")
    expect(page).not_to have_link("Manage menu")
    expect(page).not_to have_link("Manage ingredients")
    expect(page).not_to have_link("Manage recipes")
  end

  it "shows admins the management links and logout" do
    admin = create(:user, :admin, full_name: "Admin Nav")
    visit login_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_link("Manage staff accounts", href: admin_users_path)
    expect(page).to have_link("Manage menu", href: admin_menu_items_path)
    expect(page).to have_link("Manage ingredients", href: admin_ingredients_path)
    expect(page).to have_link("Manage recipes", href: admin_recipe_items_path)
    expect(page).to have_link("Stock entries", href: admin_stock_entries_path)
    expect(page).to have_button("Log out")
  end
end
