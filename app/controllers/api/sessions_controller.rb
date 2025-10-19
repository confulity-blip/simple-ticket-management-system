class Api::SessionsController < ApplicationController
  # POST /api/sessions
  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      # Create session (for development/local)
      session[:user_id] = user.id

      # Generate JWT token (for production/cross-domain)
      token = JsonWebToken.encode(user_id: user.id)

      render json: {
        user: user_json(user),
        token: token,
        message: 'Logged in successfully'
      }, status: :created
    else
      render json: {
        error: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  # DELETE /api/sessions
  def destroy
    session.delete(:user_id)
    head :no_content
  end

  # GET /api/sessions/current (or /api/me)
  def current
    if current_user
      render json: { user: user_json(current_user) }
    else
      render json: { user: nil }, status: :unauthorized
    end
  end

  private

  def user_json(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.role
    }
  end
end
