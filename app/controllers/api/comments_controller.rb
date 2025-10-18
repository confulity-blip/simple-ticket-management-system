class Api::CommentsController < ApplicationController
  before_action :require_login
  before_action :set_ticket

  # GET /api/tickets/:ticket_id/comments
  def index
    authorize @ticket, :show?

    @comments = @ticket.comments.includes(:user).chronological

    # Customers can only see public comments
    @comments = @comments.public_comments if current_user.customer?

    render json: {
      comments: @comments.map { |c| comment_json(c) }
    }
  end

  # POST /api/tickets/:ticket_id/comments
  def create
    authorize @ticket, :comment?

    @comment = @ticket.comments.build(comment_params)
    @comment.user = current_user

    # Only agents/admins can create internal notes
    if @comment.internal? && !current_user.admin? && !current_user.agent?
      return render json: {
        error: 'Only agents and admins can create internal notes'
      }, status: :forbidden
    end

    if @comment.save
      render json: {
        comment: comment_json(@comment),
        message: 'Comment added successfully'
      }, status: :created
    else
      render json: {
        errors: @comment.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Ticket not found' }, status: :not_found
  end

  def comment_params
    params.require(:comment).permit(:body, :public)
  end

  def comment_json(comment)
    {
      id: comment.id,
      body: comment.body,
      public: comment.public,
      author: {
        id: comment.user.id,
        full_name: comment.user.full_name,
        role: comment.user.role
      },
      created_at: comment.created_at,
      updated_at: comment.updated_at
    }
  end
end
