module CurrentUser
  extend ActiveSupport::Concern

  included do
    # Make current_user available in controllers
    helper_method :current_user if respond_to?(:helper_method)
  end

  # Returns the currently logged-in user (if any)
  # Supports both JWT (from Authorization header) and session-based auth
  def current_user
    @current_user ||= user_from_token || user_from_session
  end

  # Returns true if user is logged in
  def logged_in?
    current_user.present?
  end

  # Requires user to be logged in
  def require_login
    unless logged_in?
      render json: { error: 'You must be logged in to access this resource' },
             status: :unauthorized
    end
  end

  # Requires user to be an admin
  def require_admin
    unless current_user&.admin?
      render json: { error: 'You must be an admin to access this resource' },
             status: :forbidden
    end
  end

  # Requires user to be an admin or agent
  def require_agent
    unless current_user&.admin? || current_user&.agent?
      render json: { error: 'You must be an agent or admin to access this resource' },
             status: :forbidden
    end
  end

  private

  # Get user from JWT token in Authorization header
  def user_from_token
    token = request.headers['Authorization']&.split(' ')&.last
    return nil unless token

    decoded = JsonWebToken.decode(token)
    User.find_by(id: decoded[:user_id]) if decoded
  rescue
    nil
  end

  # Get user from session (fallback for development)
  def user_from_session
    User.find_by(id: session[:user_id]) if session[:user_id]
  end
end
