# app/policies/parties/base_child_policy.rb
class Parties::BasePolicy < ApplicationPolicy
  def index?  ; PartyPolicy.new(user, party_for(record)).show?   ; end
  def show?   ; index?                                           ; end
  def create? ; PartyPolicy.new(user, party_for(record)).update? ; end
  def update? ; create?                                          ; end
  def destroy?; user&.system_admin?                              ; end

  class Scope < ApplicationPolicy::Scope
    def resolve = scope
  end

  private
  def party_for(rec) = rec.respond_to?(:party) ? rec.party : Party
end
