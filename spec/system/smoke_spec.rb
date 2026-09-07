require "rails_helper"

RSpec.describe "Home page", type: :system do
  it "boots the app and loads the home page" do
    visit root_path
    expect(page).to have_text("Aafnai Coffee")
  end
end