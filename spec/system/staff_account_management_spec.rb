require "rails_helper"

RSpec.describe "Staff account management", type: :system do
  it "creates, lists, and deactivates a staff account, and the deactivated user cannot log in" do
    admin = create(:user, :admin, full_name: "Admin One")
    visit login_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Admin One.")
    click_link "Manage staff accounts"

    expect(page).to have_text("Staff accounts")
    click_link "New staff account"

    fill_in "Full name", with: "Barista Two"
    fill_in "Email", with: "barista2@example.com"
    fill_in "Password", with: "password123"
    select "Staff", from: "Role"
    click_button "Create staff account"

    expect(page).to have_text("Staff account created for Barista Two.")
    expect(page).to have_text("Barista Two")
    expect(page).to have_text("barista2@example.com")

    accept_confirm do
      within "tr", text: "Barista Two" do
        click_button "Deactivate"
      end
    end

    expect(page).to have_text("Deactivated")

    visit root_path
    click_button "Log out"
    expect(page).to have_text("You have been logged out.")

    visit login_path
    fill_in "Email", with: "barista2@example.com"
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Invalid email or password.")
  end
end
