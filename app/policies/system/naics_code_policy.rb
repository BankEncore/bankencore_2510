module System
  class NaicsCodePolicy < ApplicationPolicy
    def index? = true
    def show?  = true
    class Scope < ApplicationPolicy::Scope; def resolve = scope.all; end
  end
end
