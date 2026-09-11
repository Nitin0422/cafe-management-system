# frozen_string_literal: true

module Staff
  # Counter-side customer registration (T7, PRD assumption). Any employee
  # (admin or staff) may create a customer account when none exists, e.g. at
  # the counter. The role is always customer.
  class CustomersController < ApplicationController
    before_action :require_any_employee

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      @user.role = :customer

      if @user.save
        redirect_to root_path, notice: "Customer account created for #{@user.full_name}."
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def user_params
      params.require(:user).permit(:full_name, :email, :phone, :password)
    end
  end
end
