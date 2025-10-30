# app/policies/parties/party_policy.rb
class Parties::PartyPolicy < ApplicationPolicy
  def index?
    user&.can?("parties.read") || user&.can?("admin.access")
  end

  def show?    = index?
  def create?  = user&.can?("parties.write") || user&.can?("admin.access")
  def update?  = create?
  def destroy? = user&.can?("parties.admin") || user&.can?("admin.access")

  class Scope < Scope
    def resolve
      return scope.none unless user&.can?("parties.read") || user&.can?("admin.access")
      scope.all
    end
  end
end
