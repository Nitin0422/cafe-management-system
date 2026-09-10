require "rails_helper"

RSpec.describe "Customer sessions", type: :request do
  let(:customer) { create(:user, :customer, email: "cust@example.com", phone: "+977-9800000001") }

  describe "GET /customer/login" do
    it "renders the customer login form when unauthenticated" do
      get customer_login_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Customer log in")
      expect(response.body).to include("Email or phone")
    end

    it "redirects a logged-in customer to the root path" do
      log_in_directly(customer)

      get customer_login_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /customer/login" do
    it "logs in a customer with email and password" do
      post customer_login_path, params: { identifier: customer.email, password: "password123" }
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(customer.id)
    end

    it "logs in a customer with phone and password" do
      post customer_login_path, params: { identifier: customer.phone, password: "password123" }
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(customer.id)
    end

    it "is case-insensitive and strips whitespace on the email identifier" do
      post customer_login_path, params: { identifier: "  #{customer.email.upcase}  ", password: "password123" }
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(customer.id)
    end

    it "strips surrounding whitespace on the phone identifier" do
      post customer_login_path, params: { identifier: "  #{customer.phone}  ", password: "password123" }
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(customer.id)
    end

    it "rotates the session id after successful login (session fixation protection)" do
      get customer_login_path
      pre_login_session_id = request.session.id

      post customer_login_path, params: { identifier: customer.email, password: "password123" }

      expect(response).to redirect_to(root_path)
      expect(request.session.id).to be_present
      expect(request.session.id).not_to eq(pre_login_session_id)
    end

    it "rejects a wrong password with a generic error" do
      post customer_login_path, params: { identifier: customer.email, password: "wrong-password" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email, phone, or password.")
    end

    it "rejects an unknown identifier with the same generic error (no enumeration)" do
      post customer_login_path, params: { identifier: "nobody@example.com", password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email, phone, or password.")
    end

    it "rejects an inactive customer even with valid credentials" do
      inactive = create(:user, :customer, active: false)
      post customer_login_path, params: { identifier: inactive.email, password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email, phone, or password.")
    end

    it "rejects staff even with valid credentials (entry-point separation)" do
      staff = create(:user, :staff)
      post customer_login_path, params: { identifier: staff.email, password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email, phone, or password.")
    end

    it "rejects an admin even with valid credentials (entry-point separation)" do
      admin = create(:user, :admin)
      post customer_login_path, params: { identifier: admin.email, password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
    end

    it "does not accept a customer via the employee login entry point" do
      post login_path, params: { email: customer.email, password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email or password.")
    end
  end
end
