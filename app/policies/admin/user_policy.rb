# app/policies/admin/user_policy.rb
module Admin
  class UserPolicy < ApplicationPolicy
    def index?  = adminish?
    def show?   = adminish?
    def update? = adminish?

    class Scope < Scope
      def resolve
        adminish? ? scope.all : scope.none
      end

      private

      def adminish?
        return false unless user
        (user.respond_to?(:admin?)        && user.admin?) ||
        (user.respond_to?(:system_admin?) && user.system_admin?) ||
        (user.respond_to?(:roles) && user.roles.where(key: %w[admin system_admin]).exists?)
      end
    end

    private

    def adminish?
      Scope.new(user, User).send(:adminish?)
    end
  end
end
