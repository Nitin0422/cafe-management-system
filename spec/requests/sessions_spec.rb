require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "renders the login form when unauthenticated" do
      get login_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Log in")
    end

    it "redirects authenticated users to the root path" do
      user = create(:user, :admin)
      log_in(user)
      get login_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /login" do
    it "logs in an admin with valid credentials" do
      admin = create(:user, :admin)
      post login_path, params: { email: admin.email, password: "password123" }
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(admin.id)
    end

    it "logs in a staff member with valid credentials" do
      staff = create(:user, :staff)
      post login_path, params: { email: staff.email, password: "password123" }
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(staff.id)
    end

    it "is case-insensitive and strips whitespace on email" do
      staff = create(:user, :staff)
      post login_path, params: { email: "  #{staff.email.upcase}  ", password: "password123" }
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(staff.id)
    end

    it "rejects a wrong password with a generic error" do
      staff = create(:user, :staff)
      post login_path, params: { email: staff.email, password: "wrong-password" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email or password.")
    end

    it "rejects an unknown email with the same generic error (no enumeration)" do
      post login_path, params: { email: "nobody@example.com", password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email or password.")
    end

    it "rejects an inactive user even with valid credentials" do
      inactive = create(:user, :staff, active: false)
      post login_path, params: { email: inactive.email, password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email or password.")
    end
  end

  describe "DELETE /logout" do
    it "clears the session and redirects to login" do
      user = create(:user, :admin)
      log_in(user)
      expect(session[:user_id]).to eq(user.id)

      delete logout_path
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
    end
  end
end
