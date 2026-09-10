# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    # User.authenticate_identifier handles both lookup normalization and the
    # timing-uniform dummy-digest comparison for unknown identifiers; see the
    # User model. Employees (admin/staff) log in here with email+password;
    # customer login with email OR phone is T7's CustomerSessionsController.
    user = User.authenticate_identifier(params[:email], params[:password])

    if user&.active && (user.admin? || user.staff?)
      # Reset the session before signing in (OWASP session-fixation
      # protection) so a pre-auth session id cannot be reused after login.
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome back, #{user.full_name}."
    else
      # Generic error to avoid user enumeration; never reveal whether the
      # email, the password, the role, or the active flag caused the failure.
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: "You have been logged out."
  end
end
