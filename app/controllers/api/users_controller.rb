class Api::UsersController < ApplicationController
  before_action :require_login
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /api/users
  def index
    authorize User
    @users = User.all.order(:full_name)

    render json: {
      users: @users.map { |u| user_json(u) }
    }
  end

  # GET /api/users/agents
  def agents
    authorize User, :index?
    @agents = User.where(role: [:admin, :agent]).order(:full_name)

    render json: {
      agents: @agents.map { |u| user_json(u) }
    }
  end

  # GET /api/users/:id
  def show
    authorize @user
    render json: { user: user_detail_json(@user) }
  end

  # POST /api/users
  def create
    authorize User
    @user = User.new(user_create_params)

    if @user.save
      render json: {
        user: user_detail_json(@user),
        message: 'User created successfully'
      }, status: :created
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/users/:id
  def update
    authorize @user

    if @user.update(user_update_params)
      render json: {
        user: user_detail_json(@user),
        message: 'User updated successfully'
      }
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/users/:id
  def destroy
    authorize @user
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_create_params
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name, :role)
  end

  def user_update_params
    # Only admins can change roles
    if current_user.admin?
      params.require(:user).permit(:email, :full_name, :role, :password, :password_confirmation)
    else
      params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
    end
  end

  def user_json(user)
    {
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      role: user.role
    }
  end

  def user_detail_json(user)
    user_json(user).merge(
      created_at: user.created_at,
      updated_at: user.updated_at
    )
  end
end
