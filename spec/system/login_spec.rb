require "rails_helper"

RSpec.describe "Login flow", type: :system do
  it "logs in and out via the UI" do
    staff = create(:user, :staff, full_name: "Barista One")

    visit root_path
    click_link "Log in"

    fill_in "Email", with: staff.email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_text("Welcome back, Barista One.")

    click_button "Log out"
    expect(page).to have_text("You have been logged out.")
    expect(page).to have_current_path(login_path)
  end

  it "shows a generic error on invalid credentials" do
    visit login_path
    fill_in "Email", with: "wrong@example.com"
    fill_in "Password", with: "nope"
    click_button "Log in"

    expect(page).to have_text("Invalid email or password.")
  end
end
