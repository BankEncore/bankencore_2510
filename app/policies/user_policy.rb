class UserPolicy < ApplicationPolicy
  def index?; false; end
  def show?; record.id == user&.id; end
  def create?; false; end
  def update?; record.id == user&.id; end
  def destroy?; false; end

  def permitted_attributes
    [ :email, :name, :time_zone ]
  end

  class Scope < Scope
    def resolve
      user ? scope.where(id: user.id) : scope.none
    end
  end
end
