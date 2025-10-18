class TicketPolicy < ApplicationPolicy
  # Scope for filtering tickets based on user role
  class Scope < Scope
    def resolve
      if user.admin? || user.agent?
        # Admins and agents can see all tickets
        scope.all
      else
        # Customers can only see their own tickets
        scope.where(requester_id: user.id)
      end
    end
  end

  # Anyone logged in can create a ticket
  def create?
    user.present?
  end

  # Can view if: admin, agent, or the requester
  def show?
    user.admin? || user.agent? || record.requester_id == user.id
  end

  # Can update if: admin, agent, or the requester (for limited fields)
  def update?
    user.admin? || user.agent? || record.requester_id == user.id
  end

  # Only admins and agents can delete
  def destroy?
    user.admin? || user.agent?
  end

  # Only admins and agents can assign tickets
  def assign?
    user.admin? || user.agent?
  end

  # Can add comments if: admin, agent, or requester
  def comment?
    user.admin? || user.agent? || record.requester_id == user.id
  end

  # Only admins and agents can add internal notes
  def internal_note?
    user.admin? || user.agent?
  end

  # Only admins and agents can resolve/close
  def resolve?
    user.admin? || user.agent?
  end

  def close?
    user.admin? || user.agent?
  end
end
