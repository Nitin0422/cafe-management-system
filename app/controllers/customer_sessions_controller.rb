# frozen_string_literal: true

# Customer login (T7, FR-7). Customers log in with email+password OR
# phone+password through this entry point. Employees (admin/staff) cannot log
# in here; their entry point remains SessionsController#create.
class CustomerSessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.authenticate_identifier(params[:identifier], params[:password])

    if user&.active && user.customer?
      # Reset the session before signing in (OWASP session-fixation
      # protection) so a pre-auth session id cannot be reused after login.
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome back, #{user.full_name}."
    else
      # Generic error to avoid user enumeration; never reveal whether the
      # identifier, the password, the role, or the active flag caused it.
      flash.now[:alert] = "Invalid email, phone, or password."
      render :new, status: :unprocessable_content
    end
  end
end
