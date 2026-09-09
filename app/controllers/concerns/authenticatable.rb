# frozen_string_literal: true

# Shared session authentication and role-based authorization.
#
# Provides:
#   * current_user        - the signed-in user (memoized from session[:user_id])
#   * Current.user        - request-scoped actor for the Attributable concern
#   * require_login       - 302 to login path when unauthenticated
#   * require_admin       - 403 for non-admins
#   * require_any_employee - 403 for customers (admin and staff pass)
#   * logout              - clear the session
#
# Roles are intentionally kept generic (admin / staff / customer) so that
# future customer-specific controllers (T7) can reuse these primitives.
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
    helper_method :current_user
    helper_method :logged_in?
  end

  private

  # Load the session user into Current.user for every request so that the
  # Attributable concern can stamp created_by/updated_by on writes.
  def set_current_user
    Current.user = current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "Please log in to continue."
  end

  def require_admin
    return if admin?

    blocked_access
  end

  # Admin and staff are allowed; customers are blocked.
  def require_any_employee
    return if admin? || staff?

    blocked_access
  end

  def admin?
    current_user&.admin?
  end

  def staff?
    current_user&.staff?
  end

  def blocked_access
    return redirect_to(login_path, alert: "Please log in to continue.") unless logged_in?

    head :forbidden
  end

  def logout
    reset_session
  end
end
