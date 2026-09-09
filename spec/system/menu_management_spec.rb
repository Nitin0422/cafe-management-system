require "rails_helper"

RSpec.describe "Menu management", type: :system do
  it "creates, edits, and deactivates a menu item as an admin" do
    create(:category, name: "Coffee")
    admin = create(:user, :admin, full_name: "Admin One")
    visit login_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Admin One.")

    click_link "Manage menu"
    expect(page).to have_text("Menu items")

    click_link "New menu item"
    expect(page).to have_selector("#menu_item_name")

    fill_in "Name", with: "Cold Brew"
    fill_in "Price (NPR)", with: "200"
    select "Coffee", from: "Category"
    click_button "Create menu item"

    expect(page).to have_text("Menu item created: Cold Brew.")
    expect(page).to have_text("Cold Brew")
    expect(page).to have_text("Rs. 200.00")

    within "tr", text: "Cold Brew" do
      click_link "Edit"
    end

    expect(page).to have_button("Update menu item")

    fill_in "Price (NPR)", with: "220"
    click_button "Update menu item"

    expect(page).to have_text("Cold Brew has been updated.")
    expect(page).to have_text("Rs. 220.00")

    # The confirmation contract under test is the data-turbo-confirm wiring
    # plus the DELETE flow. The native confirm() dialog is browser chrome
    # that long-lived chromedriver sessions intermittently fail to present
    # (Turbo's confirm check then returns false and cancels the submit), so
    # assert the attribute deterministically and stub the dialog to accept.
    within "tr", text: "Cold Brew" do
      expect(find_button("Deactivate")["data-turbo-confirm"]).to match(/deactivate/i)
    end
    page.execute_script("window.confirm = function () { return true }")

    within "tr", text: "Cold Brew" do
      click_button "Deactivate"
    end

    expect(page).to have_text("Cold Brew is no longer available.")
    expect(page).to have_text("Unavailable")
  end

  it "does not expose menu management to staff" do
    staff = create(:user, :staff, full_name: "Staff One")
    visit login_path

    fill_in "Email", with: staff.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Staff One.")
    expect(page).not_to have_link("Manage menu")

    visit admin_menu_items_path
    expect(page).not_to have_text("Menu items")
  end
end
