require "rails_helper"

RSpec.describe "Role-based authorization", type: :request do
  # Minimal echo controller that exercises the guard callbacks. Because
  # config.action_controller.raise_on_missing_callback_actions is enabled in
  # the test environment, each before_action guard must reference an action
  # that actually exists on the controller.
  class GuardEchoController < ApplicationController
    before_action :require_admin,    only: :admin_only
    before_action :require_any_employee, only: :employee_only

    def admin_only
      render plain: "admin ok"
    end

    def employee_only
      render plain: "employee ok"
    end
  end

  context "require_admin" do
    it "allows admins" do
      log_in(create(:user, :admin))
      get "/guard/admin"
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("admin ok")
    end

    it "blocks staff with 403" do
      log_in(create(:user, :staff))
      get "/guard/admin"
      expect(response).to have_http_status(:forbidden)
    end

    it "blocks customers with 403" do
      log_in(create(:user, :customer))
      get "/guard/admin"
      expect(response).to have_http_status(:forbidden)
    end

    it "redirects unauthenticated users to login" do
      get "/guard/admin"
      expect(response).to redirect_to(login_path)
    end
  end

  context "require_any_employee" do
    it "allows admins" do
      log_in(create(:user, :admin))
      get "/guard/employee"
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("employee ok")
    end

    it "allows staff" do
      log_in(create(:user, :staff))
      get "/guard/employee"
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("employee ok")
    end

    it "blocks customers with 403" do
      log_in(create(:user, :customer))
      get "/guard/employee"
      expect(response).to have_http_status(:forbidden)
    end

    it "redirects unauthenticated users to login" do
      get "/guard/employee"
      expect(response).to redirect_to(login_path)
    end
  end

  context "deactivated users" do
    it "blocks a deactivated user with an existing session" do
      user = create(:user, :staff)
      log_in(user)
      user.update!(active: false)

      get "/guard/employee"

      expect(response).to redirect_to(login_path)
    end
  end

  context "session expiry configuration" do
    it "sets an 8-hour cookie expiration" do
      # The session cookie is configured with expire_after 8.hours in
      # config/initializers/session_store.rb. Reach into the app config used
      # to build the cookie.
      store = Rails.application.config.session_store
      options = Rails.application.config.session_options
      expect(store).to eq(ActionDispatch::Session::CookieStore)
      expect(options[:expire_after]).to eq(8.hours)
    end
  end
end
