# app/policies/admin/system/naics_code_policy.rb
module Admin
  module System
    class NaicsCodePolicy < ApplicationPolicy
      def index? = can?("admin.access") && can?("system.read")
    class Scope < ApplicationPolicy::Scope
      def resolve = scope.all
    end
    end
  end
end
