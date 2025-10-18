class ApplicationController < ActionController::API
  include CurrentUser
  include Pundit::Authorization

  # Enable cookies and session for API mode
  include ActionController::Cookies

  # Pundit error handling
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Pundit uses this to get the current user
  def pundit_user
    current_user
  end

  def user_not_authorized
    render json: {
      error: 'You are not authorized to perform this action'
    }, status: :forbidden
  end
end
