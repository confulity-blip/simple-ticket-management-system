class Api::TicketsController < ApplicationController
  before_action :require_login
  before_action :set_ticket, only: [:show, :update, :destroy, :assign]

  # GET /api/tickets
  def index
    @tickets = policy_scope(Ticket)
                 .includes(:requester, :assignee, :tags)
                 .recent

    # Apply filters
    @tickets = @tickets.by_status(params[:status]) if params[:status].present?
    @tickets = @tickets.by_priority(params[:priority]) if params[:priority].present?
    @tickets = @tickets.by_category(params[:category]) if params[:category].present?
    @tickets = @tickets.assigned_to(params[:assignee_id]) if params[:assignee_id].present?
    @tickets = @tickets.created_by(params[:requester_id]) if params[:requester_id].present?

    # Search
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @tickets = @tickets.where(
        'tickets.title ILIKE ? OR tickets.description ILIKE ? OR tickets.ticket_key ILIKE ?',
        search_term, search_term, search_term
      )
    end

    # Pagination
    @tickets = @tickets.page(params[:page] || 1).per(params[:per_page] || 25)

    render json: {
      tickets: @tickets.map { |t| ticket_json(t) },
      meta: {
        current_page: @tickets.current_page,
        total_pages: @tickets.total_pages,
        total_count: @tickets.total_count,
        per_page: @tickets.limit_value
      }
    }
  end

  # GET /api/tickets/:id
  def show
    authorize @ticket
    render json: { ticket: ticket_detail_json(@ticket) }
  end

  # POST /api/tickets
  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.requester = current_user
    authorize @ticket

    if @ticket.save
      render json: {
        ticket: ticket_detail_json(@ticket),
        message: 'Ticket created successfully'
      }, status: :created
    else
      render json: {
        errors: @ticket.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/tickets/:id
  def update
    authorize @ticket

    if @ticket.update(ticket_update_params)
      render json: {
        ticket: ticket_detail_json(@ticket),
        message: 'Ticket updated successfully'
      }
    else
      render json: {
        errors: @ticket.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/tickets/:id
  def destroy
    authorize @ticket
    @ticket.destroy
    head :no_content
  end

  # POST /api/tickets/:id/assign
  def assign
    authorize @ticket, :assign?

    assignee = User.find_by(id: params[:assignee_id])

    if assignee.nil?
      return render json: { error: 'Assignee not found' }, status: :not_found
    end

    unless assignee.agent? || assignee.admin?
      return render json: { error: 'Can only assign to agents or admins' }, status: :unprocessable_entity
    end

    @ticket.assign_to(assignee)

    render json: {
      ticket: ticket_detail_json(@ticket.reload),
      message: "Ticket assigned to #{assignee.full_name}"
    }
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Ticket not found' }, status: :not_found
  end

  def ticket_params
    params.require(:ticket).permit(
      :title,
      :description,
      :priority,
      :category,
      :subcategory,
      tag_ids: []
    )
  end

  def ticket_update_params
    # Customers can only update limited fields
    if current_user.customer?
      params.require(:ticket).permit(:description)
    else
      params.require(:ticket).permit(
        :title,
        :description,
        :status,
        :priority,
        :category,
        :subcategory,
        :assignee_id,
        tag_ids: []
      )
    end
  end

  def ticket_json(ticket)
    {
      id: ticket.id,
      ticket_key: ticket.ticket_key,
      title: ticket.title,
      status: ticket.status,
      priority: ticket.priority,
      category: ticket.category,
      subcategory: ticket.subcategory,
      requester: user_summary(ticket.requester),
      assignee: ticket.assignee ? user_summary(ticket.assignee) : nil,
      tags: ticket.tags.map { |tag| { id: tag.id, name: tag.name, color: tag.color } },
      created_at: ticket.created_at,
      updated_at: ticket.updated_at
    }
  end

  def ticket_detail_json(ticket)
    ticket_json(ticket).merge(
      description: ticket.description,
      first_response_at: ticket.first_response_at,
      resolved_at: ticket.resolved_at,
      closed_at: ticket.closed_at,
      comments_count: ticket.comments.count
    )
  end

  def user_summary(user)
    {
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      role: user.role
    }
  end
end
