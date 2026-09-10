# frozen_string_literal: true

# Customer self-service registration (T7, FR-1). Customers register with an
# email AND a phone plus a password; the role is always customer regardless of
# any role value submitted.
class RegistrationsController < ApplicationController
  def new
    return redirect_to root_path if logged_in?

    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = :customer

    if @user.save
      # Reset the session before signing in (OWASP session-fixation
      # protection), same as the login controllers.
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome, #{@user.full_name}. Your account has been created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :phone, :password)
  end
end
