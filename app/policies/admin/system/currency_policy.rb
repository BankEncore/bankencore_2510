# app/policies/admin/system/currency_policy.rb
module Admin
  module System
    class CurrencyPolicy < ApplicationPolicy
      def index?   ; can?("admin.access") && can?("system.read")  ; end
      def show?    ; index?                                      ; end
      def new?     ; can?("admin.access") && can?("system.write") ; end
      def create?  ; new?                                        ; end
      def edit?    ; new?                                        ; end
      def update?  ; new?                                        ; end
      def destroy? ; can?("admin.access") && can?("system.write") ; end

      class Scope < ApplicationPolicy::Scope
        def resolve ; scope.all ; end
      end
    end
  end
end
