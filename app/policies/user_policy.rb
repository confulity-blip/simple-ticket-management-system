class UserPolicy < ApplicationPolicy
  # Scope for filtering users
  class Scope < Scope
    def resolve
      if user.admin?
        # Admins can see all users
        scope.all
      elsif user.agent?
        # Agents can see admins, agents, and customers
        scope.all
      else
        # Customers can only see themselves
        scope.where(id: user.id)
      end
    end
  end

  # Only admins can create users
  def create?
    user.admin?
  end

  # Can view if: admin, agent (can see all), or viewing yourself
  def show?
    user.admin? || user.agent? || record.id == user.id
  end

  # Can update if: admin (can update anyone), or updating yourself
  def update?
    user.admin? || record.id == user.id
  end

  # Only admins can delete users
  def destroy?
    user.admin? && record.id != user.id  # Can't delete yourself
  end

  # Only admins can change roles
  def change_role?
    user.admin?
  end

  # Only admins can list all users
  def index?
    user.admin?
  end

  # Only admins can see list of agents (for assignment)
  def agents?
    user.admin? || user.agent?
  end
end
