class StaffPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user&.owner? || false
  end

  def update?
    user&.owner? || false
  end

  def destroy?
    user&.owner? || false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
