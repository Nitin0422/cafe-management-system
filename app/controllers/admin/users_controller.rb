# frozen_string_literal: true

module Admin
  # Admin staff-account management (T4). Only admins may create or deactivate
  # staff accounts. Deactivation is a soft-deactivate (active: false) so that
  # historical attribution to the account is preserved (FR-2).
  class UsersController < ApplicationController
    before_action :require_admin

    def index
      @users = User.employees.includes(:created_by).order(:full_name, :id)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      # The role enum default is admin (0). If an invalid role were silently
      # dropped by the whitelist, a new account would default to admin instead
      # of failing. Explicitly reject any role outside admin/staff before
      # assigning it, and keep role out of mass assignment entirely.
      role = params.dig(:user, :role)
      unless %w[admin staff].include?(role)
        @user.errors.add(:role, "must be admin or staff")
        render :new, status: :unprocessable_content
        return
      end
      @user.role = role

      if @user.save
        redirect_to admin_users_path, notice: "Staff account created for #{@user.full_name}."
      else
        render :new, status: :unprocessable_content
      end
    end

    def deactivate
      @user = User.employees.find(params[:id])

      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot deactivate your own account."
        return
      end

      was_active = @user.active?

      if @user.update(active: false)
        if was_active
          redirect_to admin_users_path, notice: "#{@user.full_name}'s account has been deactivated."
        else
          redirect_to admin_users_path, notice: "#{@user.full_name}'s account is already deactivated."
        end
      else
        alert = "Could not deactivate #{@user.full_name}'s account."
        alert += " #{@user.errors.full_messages.to_sentence}" if @user.errors.any?
        redirect_to admin_users_path, alert: alert
      end
    end

    private

    def user_params
      params.require(:user).permit(:full_name, :email, :password)
    end
  end
end
