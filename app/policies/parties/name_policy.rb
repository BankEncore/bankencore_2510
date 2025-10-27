# app/policies/parties/name_policy.rb
class Parties::NamePolicy < ApplicationPolicy
  def show?    = user.system_admin?
  def create?  = user.system_admin?
  def update?  = user.system_admin?
  def destroy? = user.system_admin?
end
