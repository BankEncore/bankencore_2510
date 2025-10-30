# app/policies/parties/base_child_policy.rb
class Parties::BaseChildPolicy < ApplicationPolicy
  def index?   = party_policy.index?
  def show?    = party_policy.show?
  def create?  = party_policy.create?
  def update?  = party_policy.update?
  def destroy? = party_policy.destroy?

  class Scope < Scope
    def resolve
      Parties::PartyPolicy::Scope.new(user, scope).resolve
    end
  end

  private

  def party_policy
    @party_policy ||= Parties::PartyPolicy.new(user, Parties::Party.new)
  end
end
