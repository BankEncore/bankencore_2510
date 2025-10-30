# app/policies/admin/payments/ach_routing_policy.rb
class Admin::Payments::AchRoutingPolicy < ApplicationPolicy
  def index?
    user&.can?("admin.access") || user&.can?("system.read")
  end
  def show? = index?

  class Scope < Scope
    def resolve
      return scope.none unless user&.can?("admin.access") || user&.can?("system.read")
      scope.all
    end
  end
end
