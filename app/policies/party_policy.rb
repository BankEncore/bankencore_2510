# app/policies/party_policy.rb
class PartyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve = user.system_admin? ? scope.all : scope.none
  end

  def index? = user.system_admin?
  def show?  = user.system_admin?
  def create? = user.system_admin?
  def update? = user.system_admin?
  def destroy? = user.system_admin?
end
