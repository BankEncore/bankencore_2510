# app/policies/admin/base_policy.rb
class Admin::BasePolicy < ApplicationPolicy
  def admin_access? = user&.respond_to?(:system_admin?) && user.system_admin? ||
                      user&.respond_to?(:has_permission?) && user.has_permission?("admin.access")

  class Scope < Scope
    def resolve = admin_access? ? scope.all : scope.none
  end

  def index?  = admin_access?
  def show?   = admin_access?
  def new?    = admin_access?
  def create? = admin_access?
  def edit?   = admin_access?
  def update? = admin_access?
  def destroy? = admin_access?
end
