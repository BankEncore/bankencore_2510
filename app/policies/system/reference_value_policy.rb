class System::ReferenceValuePolicy < ApplicationPolicy
  def index?  = true
  def show?   = parent_public? || user&.admin?
  def create? = user&.admin?
  def update? = user&.admin?
  def destroy? = user&.admin?

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.joins(:reference_list).where(system_reference_lists: { visibility: "public" })
      end
    end
  end

  private
  def parent_public?
    record.reference_list.visibility == "public"
  end
end
