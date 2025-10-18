class Api::AnalyticsController < ApplicationController
  before_action :require_login

  # GET /api/analytics/dashboard
  def dashboard
    # Get ticket stats based on user role
    tickets = policy_scope(Ticket)

    # Count by status
    status_counts = {
      new: tickets.ticket_new.count,
      open: tickets.open.count,
      pending: tickets.pending.count,
      resolved: tickets.resolved.count,
      closed: tickets.closed.count
    }

    # Count by priority
    priority_counts = {
      low: tickets.low.count,
      medium: tickets.medium.count,
      high: tickets.high.count,
      urgent: tickets.urgent.count
    }

    # Recent activity (tickets resolved today)
    today_start = Time.current.beginning_of_day
    resolved_today = tickets.where('resolved_at >= ?', today_start).count

    # Average response time (in hours)
    tickets_with_response = tickets.where.not(first_response_at: nil)
    if tickets_with_response.any?
      total_seconds = tickets_with_response.sum do |t|
        t.first_response_at - t.created_at
      end
      avg_response_time_hours = (total_seconds / tickets_with_response.count / 3600).round(1)
    else
      avg_response_time_hours = 0
    end

    # Tickets by category
    category_counts = tickets.group(:category).count

    # My assigned tickets (for agents/admins)
    if current_user.agent? || current_user.admin?
      my_assigned_count = tickets.where(assignee_id: current_user.id).where.not(status: [:resolved, :closed]).count
    else
      my_assigned_count = nil
    end

    # Unassigned tickets (for agents/admins)
    if current_user.agent? || current_user.admin?
      unassigned_count = Ticket.where(assignee_id: nil).where.not(status: [:resolved, :closed]).count
    else
      unassigned_count = nil
    end

    render json: {
      status_counts: status_counts,
      priority_counts: priority_counts,
      category_counts: category_counts,
      metrics: {
        resolved_today: resolved_today,
        avg_response_time_hours: avg_response_time_hours,
        my_assigned: my_assigned_count,
        unassigned: unassigned_count,
        total_tickets: tickets.count
      }
    }
  end
end
