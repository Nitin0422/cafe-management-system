require "rails_helper"

RSpec.describe "Admin ingredient management", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }
  let(:customer) { create(:user, :customer) }
  let(:ingredient) { create(:ingredient, name: "Coffee Beans", unit: "g", low_stock_threshold: 500) }

  describe "authorization" do
    context "unauthenticated" do
      it "redirects index to login" do
        get admin_ingredients_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects new to login" do
        get new_admin_ingredient_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects create to login" do
        post admin_ingredients_path, params: { ingredient: { name: "Milk", unit: "ml" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects edit to login" do
        get edit_admin_ingredient_path(ingredient)
        expect(response).to redirect_to(login_path)
      end

      it "redirects update to login" do
        patch admin_ingredient_path(ingredient), params: { ingredient: { name: "Renamed" } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "as staff" do
      before { log_in(staff) }

      it "blocks index with 403" do
        get admin_ingredients_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks new with 403" do
        get new_admin_ingredient_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_ingredients_path, params: { ingredient: { name: "Milk", unit: "ml" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks edit with 403" do
        get edit_admin_ingredient_path(ingredient)
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks update with 403" do
        patch admin_ingredient_path(ingredient), params: { ingredient: { name: "Renamed" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as customer" do
      before { log_in_directly(customer) }

      it "blocks index with 403" do
        get admin_ingredients_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_ingredients_path, params: { ingredient: { name: "Milk", unit: "ml" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as admin" do
      before { log_in(admin) }

      it "allows index" do
        get admin_ingredients_path
        expect(response).to have_http_status(:ok)
      end

      it "allows new" do
        get new_admin_ingredient_path
        expect(response).to have_http_status(:ok)
      end

      it "allows edit" do
        get edit_admin_ingredient_path(ingredient)
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post admin_ingredients_path, params: { ingredient: { name: "Milk", unit: "ml", low_stock_threshold: "100" } }
        expect(response).to redirect_to(admin_ingredients_path)
      end

      it "allows update" do
        patch admin_ingredient_path(ingredient), params: { ingredient: { name: "Renamed", unit: "g" } }
        expect(response).to redirect_to(admin_ingredients_path)
      end
    end
  end

  describe "GET /admin/ingredients" do
    before { log_in(admin) }

    it "lists ingredients with unit, current stock, threshold, and status" do
      low = create(:ingredient, name: "Milk", unit: "ml", low_stock_threshold: "500")
      create(:stock_entry, ingredient: low, quantity: 50)
      ok = create(:ingredient, name: "Sugar", unit: "kg", low_stock_threshold: "2")
      create(:stock_entry, ingredient: ok, quantity: 10)

      get admin_ingredients_path

      expect(response.body).to include("Milk")
      expect(response.body).to include("ml")
      expect(response.body).to include("Sugar")
      expect(response.body).to include("kg")
      expect(response.body).to include("Low stock")
      expect(response.body).to include("OK")
    end
  end

  describe "POST /admin/ingredients" do
    before { log_in(admin) }

    it "creates an ingredient and records created_by" do
      expect do
        post admin_ingredients_path, params: { ingredient: { name: "Whole Milk", unit: "ml", low_stock_threshold: "250" } }
      end.to change(Ingredient, :count).by(1)

      created = Ingredient.find_by(name: "Whole Milk")
      expect(created).to have_attributes(unit: "ml", low_stock_threshold: 250.0)
      expect(created.created_by).to eq(admin)
      expect(response).to redirect_to(admin_ingredients_path)
      expect(flash[:notice]).to be_present
    end

    it "defaults the low-stock threshold to zero" do
      post admin_ingredients_path, params: { ingredient: { name: "Water", unit: "l" } }

      expect(Ingredient.find_by(name: "Water").low_stock_threshold).to eq(0.0)
    end

    it "rejects a blank name with 422 and no record" do
      expect do
        post admin_ingredients_path, params: { ingredient: { name: "", unit: "g" } }
      end.not_to change(Ingredient, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate name with 422 and no record" do
      existing = create(:ingredient, name: "Coffee Beans")
      expect do
        post admin_ingredients_path, params: { ingredient: { name: existing.name, unit: "g" } }
      end.not_to change(Ingredient, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a missing unit with 422 and no record" do
      expect do
        post admin_ingredients_path, params: { ingredient: { name: "Milk" } }
      end.not_to change(Ingredient, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a negative low-stock threshold with 422 and no record" do
      expect do
        post admin_ingredients_path, params: { ingredient: { name: "Milk", unit: "ml", low_stock_threshold: "-5" } }
      end.not_to change(Ingredient, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /admin/ingredients/:id" do
    before { log_in(admin) }

    it "updates the ingredient and records updated_by" do
      patch admin_ingredient_path(ingredient), params: { ingredient: { name: "Coffee Beans (Roasted)", unit: "kg", low_stock_threshold: "1" } }

      expect(response).to redirect_to(admin_ingredients_path)
      updated = ingredient.reload
      expect(updated).to have_attributes(name: "Coffee Beans (Roasted)", unit: "kg", low_stock_threshold: 1.0)
      expect(updated.updated_by).to eq(admin)
    end

    it "rejects a blank name with 422 and no change" do
      expect do
        patch admin_ingredient_path(ingredient), params: { ingredient: { name: "", unit: "g" } }
      end.not_to change { ingredient.reload.name }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
