require "rails_helper"

RSpec.describe "Customer registration", type: :request do
  describe "GET /register" do
    it "renders the registration form when unauthenticated" do
      get register_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Register")
      expect(response.body).to include("Full name")
      expect(response.body).to include("Email")
      expect(response.body).to include("Phone")
    end

    it "redirects a logged-in customer to the root path" do
      customer = create(:user, :customer)
      log_in_directly(customer)

      get register_path
      expect(response).to redirect_to(root_path)
    end

    it "redirects a logged-in staff member to the root path" do
      staff = create(:user, :staff)
      log_in(staff)

      get register_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /register" do
    it "creates a customer account, signs the user in, and redirects to root" do
      expect do
        post register_path, params: { user: { full_name: "New Customer", email: "newcust@example.com", phone: "+977-9800000001", password: "password123" } }
      end.to change(User, :count).by(1)

      created = User.find_by(email: "newcust@example.com")
      expect(created).to have_attributes(full_name: "New Customer", phone: "+977-9800000001", role: "customer")
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(created.id)
      expect(flash[:notice]).to be_present
    end

    it "rotates the session id after registration (session fixation protection)" do
      get register_path
      pre_registration_session_id = request.session.id

      post register_path, params: { user: { full_name: "New Customer", email: "rotated@example.com", phone: "+977-9800000007", password: "password123" } }

      expect(response).to redirect_to(root_path)
      expect(request.session.id).to be_present
      expect(request.session.id).not_to eq(pre_registration_session_id)
    end

    it "forces the role to customer even when a different role is submitted" do
      post register_path, params: { user: { full_name: "Sneaky", email: "sneaky@example.com", phone: "+977-9800000002", password: "password123", role: "admin" } }

      expect(User.find_by(email: "sneaky@example.com").role).to eq("customer")
    end

    it "rejects a missing email with 422 and no record" do
      expect do
        post register_path, params: { user: { full_name: "No Email", email: "", phone: "+977-9800000003", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a missing phone with 422 and no record" do
      expect do
        post register_path, params: { user: { full_name: "No Phone", email: "nophone@example.com", phone: "", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a missing password with 422 and no record" do
      expect do
        post register_path, params: { user: { full_name: "No Pass", email: "nopass@example.com", phone: "+977-9800000004", password: "" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate email with 422 and no record" do
      create(:user, :customer, email: "dupcust@example.com")
      expect do
        post register_path, params: { user: { full_name: "Dup", email: "dupcust@example.com", phone: "+977-9800000005", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate phone with 422 and no record" do
      create(:user, :customer, phone: "+977-9800000006")
      expect do
        post register_path, params: { user: { full_name: "Dup", email: "dupphone@example.com", phone: "+977-9800000006", password: "password123" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
