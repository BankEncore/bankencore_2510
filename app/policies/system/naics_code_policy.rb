# app/policies/system/naics_code_policy.rb
class System::NaicsCodePolicy < ApplicationPolicy
  # Public read-only access (adjust if you want to require a permission)
  def index? = true
  def show?  = true

  class Scope < Scope
    def resolve = scope.all
  end
end
