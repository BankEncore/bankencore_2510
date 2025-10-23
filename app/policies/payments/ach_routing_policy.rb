# app/policies/payments/ach_routing_policy.rb
# new
class Payments::AchRoutingPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.all
  end
end
