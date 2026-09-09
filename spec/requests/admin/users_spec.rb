require "rails_helper"

RSpec.describe "Admin staff account management", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }
  let(:customer) { create(:user, :customer) }

  describe "authorization" do
    context "unauthenticated" do
      it "redirects index to login" do
        get admin_users_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects new to login" do
        get new_admin_user_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects create to login" do
        post admin_users_path, params: { user: { full_name: "X", email: "x@example.com", password: "password123", role: "staff" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects deactivate to login" do
        target = create(:user, :staff)
        post deactivate_admin_user_path(target)
        expect(response).to redirect_to(login_path)
      end
    end

    context "as staff" do
      before { log_in(staff) }

      it "blocks index with 403" do
        get admin_users_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks new with 403" do
        get new_admin_user_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_users_path, params: { user: { full_name: "X", email: "x@example.com", password: "password123", role: "staff" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks deactivate with 403" do
        target = create(:user, :staff)
        post deactivate_admin_user_path(target)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as customer" do
      before { log_in_directly(customer) }

      it "blocks index with 403" do
        get admin_users_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks new with 403" do
        get new_admin_user_path
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks create with 403" do
        post admin_users_path, params: { user: { full_name: "X", email: "x@example.com", password: "password123", role: "staff" } }
        expect(response).to have_http_status(:forbidden)
      end

      it "blocks deactivate with 403" do
        target = create(:user, :staff)
        post deactivate_admin_user_path(target)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as admin" do
      before { log_in(admin) }

      it "allows index" do
        get admin_users_path
        expect(response).to have_http_status(:ok)
      end

      it "allows new" do
        get new_admin_user_path
        expect(response).to have_http_status(:ok)
      end

      it "allows create" do
        post admin_users_path, params: { user: { full_name: "New Staff", email: "new@example.com", password: "password123", role: "staff" } }
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end

  describe "GET /admin/users" do
    before { log_in(admin) }

    it "lists admins and staff but not customers" do
      other_admin = create(:user, :admin, full_name: "Other Admin")
      other_staff = create(:user, :staff, full_name: "Other Staff")
      a_customer = create(:user, :customer, full_name: "A Customer")

      get admin_users_path

      expect(response.body).to include("Other Admin")
      expect(response.body).to include("Other Staff")
      expect(response.body).not_to include("A Customer")
    end
  end

  describe "POST /admin/users" do
    before { log_in(admin) }

    it "creates a staff user and records created_by as the acting admin" do
      expect do
        post admin_users_path, params: { user: { full_name: "New Staff", email: "new@example.com", password: "password123", role: "staff" } }
      end.to change(User, :count).by(1)

      created = User.find_by(email: "new@example.com")
      expect(created).to have_attributes(full_name: "New Staff", role: "staff")
      expect(created.created_by).to eq(admin)
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to be_present
    end

    it "creates an admin user" do
      post admin_users_path, params: { user: { full_name: "New Admin", email: "newadmin@example.com", password: "password123", role: "admin" } }
      created = User.find_by(email: "newadmin@example.com")
      expect(created).to have_attributes(full_name: "New Admin", role: "admin")
      expect(response).to redirect_to(admin_users_path)
    end

    it "rejects a customer role with 422 and no record" do
      expect do
        post admin_users_path, params: { user: { full_name: "Sneaky", email: "sneaky@example.com", password: "password123", role: "customer" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects missing email with 422 and no record" do
      expect do
        post admin_users_path, params: { user: { full_name: "No Email", email: "", password: "password123", role: "staff" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects missing password with 422 and no record" do
      expect do
        post admin_users_path, params: { user: { full_name: "No Pass", email: "nopass@example.com", password: "", role: "staff" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate email with 422 and no record" do
      existing = create(:user, :staff)
      expect do
        post admin_users_path, params: { user: { full_name: "Dup", email: existing.email, password: "password123", role: "staff" } }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /admin/users/:id/deactivate" do
    before { log_in(admin) }

    it "sets active to false without deleting the row" do
      target = create(:user, :staff)
      expect do
        post deactivate_admin_user_path(target)
      end.not_to change(User, :count)

      expect(target.reload.active).to be(false)
      expect(response).to redirect_to(admin_users_path)
    end

    it "records updated_by as the acting admin" do
      target = create(:user, :staff)
      post deactivate_admin_user_path(target)

      expect(target.reload.updated_by).to eq(admin)
    end

    it "prevents the deactivated staff from logging in" do
      target = create(:user, :staff)
      post deactivate_admin_user_path(target)

      # Clear the admin's session so the failed login is a fresh attempt.
      delete logout_path
      post login_path, params: { email: target.email, password: "password123" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("Invalid email or password.")
    end

    it "invalidates the deactivated user's existing session" do
      target = create(:user, :staff)
      post deactivate_admin_user_path(target)
      expect(target.reload.active).to be(false)

      # Simulate the target's pre-existing session (test-only endpoint, no
      # auth checks) and confirm it stops authenticating after deactivation.
      log_in_directly(target)
      expect(session[:user_id]).to eq(target.id)

      get root_path
      expect(session[:user_id]).to be_nil
    end

    it "allows an admin to deactivate another admin" do
      other_admin = create(:user, :admin)
      expect do
        post deactivate_admin_user_path(other_admin)
      end.not_to change(User, :count)

      expect(other_admin.reload.active).to be(false)
    end

    it "does not allow an admin to deactivate their own account" do
      post deactivate_admin_user_path(admin)

      expect(admin.reload.active).to be(true)
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to be_present
    end

    it "is idempotent when the account is already inactive" do
      target = create(:user, :staff, active: false)
      expect do
        post deactivate_admin_user_path(target)
      end.not_to change(User, :count)

      expect(target.reload.active).to be(false)
      expect(response).to redirect_to(admin_users_path)
    end

    it "returns 404 when deactivating a customer id" do
      customer # ensure the customer exists before the count assertion
      expect do
        post deactivate_admin_user_path(customer)
      end.not_to change(User, :count)

      expect(response).to have_http_status(:not_found)
      expect(customer.reload.active).to be(true)
    end
  end
end
