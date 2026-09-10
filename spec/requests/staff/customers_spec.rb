require "rails_helper"

RSpec.describe "Staff counter customer registration", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }
  let(:customer) { create(:user, :customer) }
  let(:valid_params) do
    { user: { full_name: "Counter Customer", email: "cc@example.com", phone: "+977-9800000001", password: "password123" } }
  end

  describe "authorization" do
    context "unauthenticated" do
      it "redirects new to login" do
        get new_staff_customer_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects create to login" do
        post staff_customers_path, params: valid_params
        expect(response).to redirect_to(login_path)
      end
    end

    context "as customer" do
      before { log_in_directly(customer) }

      it "blocks new with 403" do
        get new_staff_customer_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post staff_customers_path, params: valid_params
        expect(response).to have_http_status(:forbidden)
      end

      it "does not create a record" do
        expect do
          post staff_customers_path, params: valid_params
        end.not_to change(User, :count)
      end
    end

    context "as staff" do
      before { log_in(staff) }

      it "allows new" do
        get new_staff_customer_path
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post staff_customers_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "as admin" do
      before { log_in(admin) }

      it "allows new" do
        get new_staff_customer_path
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post staff_customers_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /staff/customers" do
    before { log_in(staff) }

    it "creates a customer account and records created_by as the acting employee" do
      expect do
        post staff_customers_path, params: valid_params
      end.to change(User, :count).by(1)

      created = User.find_by(email: "cc@example.com")
      expect(created).to have_attributes(full_name: "Counter Customer", phone: "+977-9800000001", role: "customer")
      expect(created.created_by).to eq(staff)
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to be_present
    end

    it "does not sign the employee out into the customer's session" do
      post staff_customers_path, params: valid_params
      expect(session[:user_id]).to eq(staff.id)
    end

    it "forces the role to customer even when a different role is submitted" do
      post staff_customers_path, params: { user: { full_name: "Sneaky", email: "sneaky@example.com", phone: "+977-9800000002", password: "password123", role: "admin" } }

      expect(User.find_by(email: "sneaky@example.com").role).to eq("customer")
    end

    it "rejects a missing phone with 422 and no record" do
      expect do
        post staff_customers_path, params: { user: { full_name: "No Phone", email: "nophone@example.com", phone: "", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate email with 422 and no record" do
      create(:user, :customer, email: "dup@example.com")
      expect do
        post staff_customers_path, params: { user: { full_name: "Dup", email: "dup@example.com", phone: "+977-9800000003", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate phone with 422 and no record" do
      create(:user, :customer, phone: "+977-9800000004")
      expect do
        post staff_customers_path, params: { user: { full_name: "Dup", email: "dupphone@example.com", phone: "+977-9800000004", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a phone that is also used by a staff account with 422 and no record" do
      create(:user, :staff, phone: "+977-9800000005")
      expect do
        post staff_customers_path, params: { user: { full_name: "Dup", email: "dupstaff@example.com", phone: "+977-9800000005", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
