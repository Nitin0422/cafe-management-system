# frozen_string_literal: true

# Test-only controller that signs in an arbitrary user by id through a real
# request, producing the same session state a successful login creates. This
# lets authorization specs exercise guards for any role, including customers,
# who cannot obtain a session through the email+password login form (customer
# login is T7).
class TestSessionsController < ApplicationController
  def create
    reset_session
    session[:user_id] = User.find(params[:user_id]).id
    head :no_content
  end
end
