require "rails_helper"

RSpec.describe "Stock entry recording", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }
  let(:customer) { create(:user, :customer) }
  let(:ingredient) { create(:ingredient, name: "Milk", unit: "ml") }

  describe "authorization" do
    context "unauthenticated" do
      it "redirects index to login" do
        get admin_stock_entries_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects new to login" do
        get new_admin_stock_entry_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects create to login" do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "restock", quantity: "100" } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "as customer" do
      before { log_in_directly(customer) }

      it "blocks index with 403" do
        get admin_stock_entries_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks new with 403" do
        get new_admin_stock_entry_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "restock", quantity: "100" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as admin" do
      before { log_in(admin) }

      it "allows index" do
        get admin_stock_entries_path
        expect(response).to have_http_status(:ok)
      end

      it "allows new" do
        get new_admin_stock_entry_path
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "restock", quantity: "100" } }
        expect(response).to redirect_to(admin_stock_entries_path)
      end
    end

    context "as staff" do
      before { log_in(staff) }

      it "allows index" do
        get admin_stock_entries_path
        expect(response).to have_http_status(:ok)
      end

      it "allows new" do
        get new_admin_stock_entry_path
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "correction", quantity: "-10" } }
        expect(response).to redirect_to(admin_stock_entries_path)
      end
    end
  end

  describe "GET /admin/stock_entries" do
    before { log_in(staff) }

    it "lists entries with ingredient, type, quantity, reference, note, and recorder" do
      create(:stock_entry, ingredient: ingredient, quantity: 100, entry_type: :restock, reference: "INV-001", note: "Morning delivery", created_by: staff)
      create(:stock_entry, ingredient: ingredient, quantity: -5, entry_type: :correction, reference: nil, note: "Spoiled", created_by: staff)

      get admin_stock_entries_path

      expect(response.body).to include("Milk")
      expect(response.body).to include("Restock")
      expect(response.body).to include("Correction")
      expect(response.body).to include("INV-001")
      expect(response.body).to include("Morning delivery")
      expect(response.body).to include("Spoiled")
      expect(response.body).to include(staff.full_name)
    end
  end

  describe "POST /admin/stock_entries" do
    before { log_in(staff) }

    it "records a restock and stamps created_by" do
      expect do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "restock", quantity: "100", reference: "INV-002", note: "Delivery" } }
      end.to change(StockEntry, :count).by(1)
        .and change { ingredient.reload.current_stock }.from(0).to(100)

      created = StockEntry.last
      expect(created).to have_attributes(ingredient: ingredient, entry_type: "restock", quantity: 100.0, reference: "INV-002", note: "Delivery")
      expect(created.created_by).to eq(staff)
      expect(response).to redirect_to(admin_stock_entries_path)
      expect(flash[:notice]).to be_present
    end

    it "records a negative correction that removes stock" do
      create(:stock_entry, ingredient: ingredient, quantity: 100, created_by: staff)

      expect do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "correction", quantity: "-10", note: "Spoiled" } }
      end.to change { ingredient.reload.current_stock }.from(100).to(90)

      expect(StockEntry.last).to have_attributes(entry_type: "correction", quantity: -10.0)
      expect(response).to redirect_to(admin_stock_entries_path)
    end

    it "rejects a missing ingredient with 422 and no entry" do
      expect do
        post admin_stock_entries_path, params: { stock_entry: { entry_type: "restock", quantity: "100" } }
      end.not_to change(StockEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a zero quantity with 422 and no entry" do
      expect do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "correction", quantity: "0" } }
      end.not_to change(StockEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a negative quantity for a restock with 422 and no entry" do
      expect do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "restock", quantity: "-50" } }
      end.not_to change(StockEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects an unknown entry type with 422 and no entry" do
      expect do
        post admin_stock_entries_path, params: { stock_entry: { ingredient_id: ingredient.id, entry_type: "bogus", quantity: "100" } }
      end.not_to change(StockEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
