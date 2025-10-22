class System::ReferenceListPolicy < ApplicationPolicy
  def index?  = true
  def show?   = record.visibility == "public" || user&.admin?
  def create? = user&.admin?
  def update? = user&.admin?
  def destroy? = user&.admin?

  class Scope < Scope
    def resolve
      user&.admin? ? scope.all : scope.where(visibility: "public")
    end
  end
end
