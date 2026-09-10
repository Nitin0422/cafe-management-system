require "rails_helper"

RSpec.describe "Admin recipe management", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }
  let(:customer) { create(:user, :customer) }
  let(:menu_item) { create(:menu_item, name: "Latte") }
  let(:ingredient) { create(:ingredient, name: "Milk", unit: "ml") }
  let(:recipe_item) { create(:recipe_item, menu_item: menu_item, ingredient: ingredient, quantity: "150") }

  describe "authorization" do
    context "unauthenticated" do
      it "redirects index to login" do
        get admin_recipe_items_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects new to login" do
        get new_admin_recipe_item_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects create to login" do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, ingredient_id: ingredient.id, quantity: "50" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects edit to login" do
        get edit_admin_recipe_item_path(recipe_item)
        expect(response).to redirect_to(login_path)
      end

      it "redirects update to login" do
        patch admin_recipe_item_path(recipe_item), params: { recipe_item: { quantity: "200" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects destroy to login" do
        delete admin_recipe_item_path(recipe_item)
        expect(response).to redirect_to(login_path)
      end
    end

    context "as staff" do
      before { log_in(staff) }

      it "blocks index with 403" do
        get admin_recipe_items_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks new with 403" do
        get new_admin_recipe_item_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, ingredient_id: ingredient.id, quantity: "50" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks edit with 403" do
        get edit_admin_recipe_item_path(recipe_item)
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks update with 403" do
        patch admin_recipe_item_path(recipe_item), params: { recipe_item: { quantity: "200" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks destroy with 403" do
        delete admin_recipe_item_path(recipe_item)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as customer" do
      before { log_in_directly(customer) }

      it "blocks index with 403" do
        get admin_recipe_items_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, ingredient_id: ingredient.id, quantity: "50" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as admin" do
      before { log_in(admin) }

      it "allows index" do
        get admin_recipe_items_path
        expect(response).to have_http_status(:ok)
      end

      it "allows new" do
        get new_admin_recipe_item_path
        expect(response).to have_http_status(:ok)
      end

      it "allows edit" do
        get edit_admin_recipe_item_path(recipe_item)
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, ingredient_id: ingredient.id, quantity: "150" } }
        expect(response).to redirect_to(admin_recipe_items_path)
      end

      it "allows update" do
        patch admin_recipe_item_path(recipe_item), params: { recipe_item: { quantity: "200" } }
        expect(response).to redirect_to(admin_recipe_items_path)
      end

      it "allows destroy" do
        delete admin_recipe_item_path(recipe_item)
        expect(response).to redirect_to(admin_recipe_items_path)
      end
    end
  end

  describe "GET /admin/recipe_items" do
    before { log_in(admin) }

    it "lists recipe lines with menu item, ingredient, quantity, and unit" do
      espresso = create(:menu_item, name: "Espresso")
      coffee = create(:ingredient, name: "Coffee", unit: "g")
      create(:recipe_item, menu_item: menu_item, ingredient: ingredient, quantity: "150")
      create(:recipe_item, menu_item: espresso, ingredient: coffee, quantity: "9")

      get admin_recipe_items_path

      expect(response.body).to include("Latte")
      expect(response.body).to include("Milk")
      expect(response.body).to include("150")
      expect(response.body).to include("ml")
      expect(response.body).to include("Espresso")
      expect(response.body).to include("Coffee")
      expect(response.body).to include("9")
    end
  end

  describe "POST /admin/recipe_items" do
    before { log_in(admin) }

    it "creates a recipe line and records created_by" do
      expect do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, ingredient_id: ingredient.id, quantity: "18" } }
      end.to change(RecipeItem, :count).by(1)

      created = RecipeItem.last
      expect(created).to have_attributes(menu_item: menu_item, ingredient: ingredient, quantity: 18.0)
      expect(created.created_by).to eq(admin)
      expect(response).to redirect_to(admin_recipe_items_path)
      expect(flash[:notice]).to be_present
    end

    it "rejects a missing menu item with 422 and no record" do
      expect do
        post admin_recipe_items_path, params: { recipe_item: { ingredient_id: ingredient.id, quantity: "18" } }
      end.not_to change(RecipeItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a missing ingredient with 422 and no record" do
      expect do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, quantity: "18" } }
      end.not_to change(RecipeItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a zero quantity with 422 and no record" do
      expect do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, ingredient_id: ingredient.id, quantity: "0" } }
      end.not_to change(RecipeItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate menu item / ingredient pair with 422 and no record" do
      create(:recipe_item, menu_item: menu_item, ingredient: ingredient, quantity: "150")

      expect do
        post admin_recipe_items_path, params: { recipe_item: { menu_item_id: menu_item.id, ingredient_id: ingredient.id, quantity: "200" } }
      end.not_to change(RecipeItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /admin/recipe_items/:id" do
    before { log_in(admin) }

    it "updates the recipe line and records updated_by" do
      other_ingredient = create(:ingredient, name: "Oat Milk", unit: "ml")

      patch admin_recipe_item_path(recipe_item), params: { recipe_item: { ingredient_id: other_ingredient.id, quantity: "200" } }

      expect(response).to redirect_to(admin_recipe_items_path)
      updated = recipe_item.reload
      expect(updated).to have_attributes(ingredient: other_ingredient, quantity: 200.0)
      expect(updated.updated_by).to eq(admin)
    end

    it "rejects a zero quantity with 422 and no change" do
      expect do
        patch admin_recipe_item_path(recipe_item), params: { recipe_item: { quantity: "0" } }
      end.not_to change { recipe_item.reload.quantity }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /admin/recipe_items/:id" do
    before { log_in(admin) }

    it "removes the recipe line" do
      recipe_item # ensure the fixture exists before the count assertion

      expect do
        delete admin_recipe_item_path(recipe_item)
      end.to change(RecipeItem, :count).by(-1)

      expect(response).to redirect_to(admin_recipe_items_path)
      expect(flash[:notice]).to be_present
    end

    it "returns 404 for a missing recipe line" do
      delete admin_recipe_item_path(id: 999_999)

      expect(response).to have_http_status(:not_found)
    end
  end
end
