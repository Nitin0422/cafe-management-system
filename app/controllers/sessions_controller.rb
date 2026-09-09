# frozen_string_literal: true

class SessionsController < ApplicationController
  # Precomputed bcrypt digest for a dummy password. Used in the unknown-email
  # branch of #create so that both known-email and unknown-email paths execute
  # exactly one bcrypt comparison, preventing email enumeration via timing.
  DUMMY_PASSWORD_DIGEST = BCrypt::Password.create("dummy-password").freeze

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    # Always perform exactly one bcrypt comparison so response time does not
    # reveal whether the email exists (timing side-channel mitigation). A
    # constant dummy digest is compared against when the email is unknown,
    # keeping cost uniform with the known-email path.
    authenticated =
      if user
        user.authenticate(params[:password])
      else
        BCrypt::Password.new(DUMMY_PASSWORD_DIGEST).is_password?(params[:password].to_s)
      end

    # T3 scopes email+password login to employees (admin/staff). Customer
    # login with phone+password is handled by T7 and is intentionally not
    # accepted here.
    if user&.active && authenticated && (user.admin? || user.staff?)
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
