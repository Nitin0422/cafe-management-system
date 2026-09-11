require "rails_helper"

RSpec.describe "Customer auth flow", type: :system do
  it "registers, logs in via phone, and logs out" do
    visit root_path
    click_link "Register"

    fill_in "Full name", with: "Aafnai Customer"
    fill_in "Email", with: "aafnai.customer@example.com"
    fill_in "Phone", with: "+977-9800000001"
    fill_in "Password", with: "password123"
    click_button "Create account"

    expect(page).to have_text("Welcome, Aafnai Customer. Your account has been created.")

    click_button "Log out"
    expect(page).to have_text("You have been logged out.")

    visit root_path
    click_link "Customer log in"

    fill_in "Email or phone", with: "+977-9800000001"
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Aafnai Customer.")
  end

  it "shows a generic error on invalid customer credentials" do
    visit customer_login_path
    fill_in "Email or phone", with: "nobody@example.com"
    fill_in "Password", with: "nope"
    click_button "Log in"

    expect(page).to have_text("Invalid email, phone, or password.")
  end
end
