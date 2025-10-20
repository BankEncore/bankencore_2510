# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user   = user
    @record = record
  end

  # default-deny
  def index?  ; false ; end
  def show?   ; false ; end
  def create? ; false ; end
  def new?    ; create? ; end
  def update? ; false ; end
  def edit?   ; update? ; end
  def destroy?; false ; end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    # Safe for AR relations, AR classes, and plain arrays
    def resolve
      if scope.respond_to?(:none)
        scope.none
      elsif scope.respond_to?(:all)
        scope.all.none # e.g., when scope is a model class
      else
        []             # non-AR collections
      end
    end
  end
end
