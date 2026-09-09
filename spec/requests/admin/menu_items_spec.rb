require "rails_helper"

RSpec.describe "Admin menu item management", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }
  let(:customer) { create(:user, :customer) }
  let(:category) { create(:category, name: "Coffee") }
  let(:menu_item) { create(:menu_item, name: "Black Coffee", price_cents: 15_000, category: category) }

  describe "authorization" do
    context "unauthenticated" do
      it "redirects index to login" do
        get admin_menu_items_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects new to login" do
        get new_admin_menu_item_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects create to login" do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "200" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects edit to login" do
        get edit_admin_menu_item_path(menu_item)
        expect(response).to redirect_to(login_path)
      end

      it "redirects update to login" do
        patch admin_menu_item_path(menu_item), params: { menu_item: { name: "Renamed" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects deactivate to login" do
        post deactivate_admin_menu_item_path(menu_item)
        expect(response).to redirect_to(login_path)
      end
    end

    context "as staff" do
      before { log_in(staff) }

      it "blocks index with 403" do
        get admin_menu_items_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks new with 403" do
        get new_admin_menu_item_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "200" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks edit with 403" do
        get edit_admin_menu_item_path(menu_item)
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks update with 403" do
        patch admin_menu_item_path(menu_item), params: { menu_item: { name: "Renamed" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks deactivate with 403" do
        post deactivate_admin_menu_item_path(menu_item)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as customer" do
      before { log_in_directly(customer) }

      it "blocks index with 403" do
        get admin_menu_items_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks new with 403" do
        get new_admin_menu_item_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "200" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks edit with 403" do
        get edit_admin_menu_item_path(menu_item)
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks update with 403" do
        patch admin_menu_item_path(menu_item), params: { menu_item: { name: "Renamed" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks deactivate with 403" do
        post deactivate_admin_menu_item_path(menu_item)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as admin" do
      before { log_in(admin) }

      it "allows index" do
        get admin_menu_items_path
        expect(response).to have_http_status(:ok)
      end

      it "allows new" do
        get new_admin_menu_item_path
        expect(response).to have_http_status(:ok)
      end

      it "allows edit" do
        get edit_admin_menu_item_path(menu_item)
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "200" } }
        expect(response).to redirect_to(admin_menu_items_path)
      end

      it "allows update" do
        patch admin_menu_item_path(menu_item), params: { menu_item: { name: "Renamed", price_rupees: "200" } }
        expect(response).to redirect_to(admin_menu_items_path)
      end

      it "allows deactivate" do
        post deactivate_admin_menu_item_path(menu_item)
        expect(response).to redirect_to(admin_menu_items_path)
      end
    end
  end

  describe "GET /admin/menu_items" do
    before { log_in(admin) }

    it "lists menu items with category and price in rupees" do
      create(:menu_item, name: "Milk Coffee", price_cents: 18_000, category: category)
      tea = create(:category, name: "Tea")
      create(:menu_item, name: "Milk Tea", price_cents: 12_000, category: tea)

      get admin_menu_items_path

      expect(response.body).to include("Milk Coffee")
      expect(response.body).to include("Milk Tea")
      expect(response.body).to include("Rs. 180.00")
      expect(response.body).to include("Rs. 120.00")
      expect(response.body).to include("Coffee")
      expect(response.body).to include("Tea")
    end

    it "marks unavailable items as Unavailable without a deactivate button" do
      create(:menu_item, name: "Hidden Item", price_cents: 5_000, category: category, available: false)

      get admin_menu_items_path

      expect(response.body).to include("Unavailable")
    end
  end

  describe "POST /admin/menu_items" do
    before { log_in(admin) }

    it "creates a menu item converting rupees to paisa and records created_by" do
      expect do
        post admin_menu_items_path, params: {
          menu_item: { name: "Cold Brew", description: "Slow-steeped.", category_id: category.id, price_rupees: "200.50", available: "1", redeemable: "1" }
        }
      end.to change(MenuItem, :count).by(1)

      created = MenuItem.find_by(name: "Cold Brew")
      expect(created).to have_attributes(description: "Slow-steeped.", price_cents: 20_050, available: true, redeemable: true)
      expect(created.category).to eq(category)
      expect(created.created_by).to eq(admin)
      expect(response).to redirect_to(admin_menu_items_path)
      expect(flash[:notice]).to be_present
    end

    it "defaults availability to true when not submitted" do
      post admin_menu_items_path, params: { menu_item: { name: "Plain Tea", category_id: category.id, price_rupees: "100" } }

      expect(MenuItem.find_by(name: "Plain Tea").available).to be(true)
    end

    it "rejects a blank name with 422 and no record" do
      expect do
        post admin_menu_items_path, params: { menu_item: { name: "", category_id: category.id, price_rupees: "200" } }
      end.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate name with 422 and no record" do
      existing = create(:menu_item, name: "Black Coffee", category: category)
      expect do
        post admin_menu_items_path, params: { menu_item: { name: existing.name, category_id: category.id, price_rupees: "200" } }
      end.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a missing category with 422 and no record" do
      expect do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", price_rupees: "200" } }
      end.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a zero price with 422 and no record" do
      expect do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "0" } }
      end.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a negative price with 422 and no record" do
      expect do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "-50" } }
      end.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a non-numeric price with 422 and no record" do
      expect do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "abc" } }
      end.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a price below one paisa with 422 and no record" do
      expect do
        post admin_menu_items_path, params: { menu_item: { name: "Cold Brew", category_id: category.id, price_rupees: "0.001" } }
      end.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /admin/menu_items/:id" do
    before { log_in(admin) }

    it "updates the item and records updated_by" do
      patch admin_menu_item_path(menu_item), params: {
        menu_item: { name: "Black Coffee (New)", price_rupees: "160", available: "0", redeemable: "1" }
      }

      expect(response).to redirect_to(admin_menu_items_path)
      updated = menu_item.reload
      expect(updated).to have_attributes(name: "Black Coffee (New)", price_cents: 16_000, available: false, redeemable: true)
      expect(updated.updated_by).to eq(admin)
    end

    it "rejects a blank name with 422 and no change" do
      expect do
        patch admin_menu_item_path(menu_item), params: { menu_item: { name: "", price_rupees: "160" } }
      end.not_to change { menu_item.reload.name }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /admin/menu_items/:id/deactivate" do
    before { log_in(admin) }

    it "sets available to false without deleting the row" do
      menu_item # ensure the fixture exists before the count assertion

      expect do
        post deactivate_admin_menu_item_path(menu_item)
      end.not_to change(MenuItem, :count)

      expect(menu_item.reload.available).to be(false)
      expect(response).to redirect_to(admin_menu_items_path)
      expect(flash[:notice]).to include("no longer available")
    end

    it "records updated_by as the acting admin" do
      post deactivate_admin_menu_item_path(menu_item)

      expect(menu_item.reload.updated_by).to eq(admin)
    end

    it "soft-deactivates an item referenced by an order item instead of failing" do
      order_item = create(:order_item, menu_item: menu_item)

      post deactivate_admin_menu_item_path(menu_item)

      expect(menu_item.reload.available).to be(false)
      expect(OrderItem.exists?(order_item.id)).to be(true)
      expect(flash[:notice]).to include("no longer available")
    end

    it "is idempotent when the item is already unavailable" do
      menu_item.update!(available: false)

      post deactivate_admin_menu_item_path(menu_item)

      expect(menu_item.reload.available).to be(false)
      expect(flash[:notice]).to include("already unavailable")
    end

    it "returns 404 for a missing item" do
      post deactivate_admin_menu_item_path(id: 999_999)

      expect(response).to have_http_status(:not_found)
    end
  end
end
