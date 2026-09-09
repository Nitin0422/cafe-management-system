# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user && user.active && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome back, #{user.full_name}."
    else
      # Generic error to avoid user enumeration; never reveal whether the
      # email, the password, or the active flag caused the failure.
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: "You have been logged out."
  end
end
