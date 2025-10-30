# app/policies/party_policy.rb
class PartyPolicy < ApplicationPolicy
  def index?  ; admin_or_staff?              ; end
  def show?   ; index?                        ; end
  def create? ; admin_or?(:onboarding?)       ; end
  def update? ; admin_or?(:operations?)       ; end
  def destroy? ; admin?                         ; end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user
      admin? ? scope.all : scope.limit(200)
    end

    private

    def admin?
      user.respond_to?(:system_admin?) && user.system_admin?
    end
  end

  private

  def admin?
    user && user.respond_to?(:system_admin?) && user.system_admin?
  end

  def admin_or_staff?
    admin? || (user && user.respond_to?(:staff?) && user.staff?)
  end

  def admin_or?(pred)
    admin? || (user && user.respond_to?(pred) && user.public_send(pred))
  end

  def resolve
    return scope.none unless user
    user.system_admin? ? scope.all : scope.limit(200)
  end
end
