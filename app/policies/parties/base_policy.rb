# app/policies/parties/base_policy.rb
class Parties::BasePolicy < ApplicationPolicy
  def index?  = user.system_admin?
  def show?   = user.system_admin?
  def create? = user.system_admin?
  def update? = user.system_admin?
  def destroy? = user.system_admin?
end
