# app/policies/application_policy.rb
# new
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Permission helper (for regular policy instances)
  def can?(perm)
    user&.can?(perm.to_s)
  end

  # Default read for signed-out is allowed only where explicitly opened
  def index?; false; end
  def show?;  false; end
  def create?; false; end
  def new?; create?; end
  def update?; false; end
  def edit?; update?; end
  def destroy?; false; end

  # Default scope denies unless overridden. Scope instances are allowed to
  # call `can?` as well (delegates to the scoped user).
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def can?(perm)
      @user&.can?(perm.to_s)
    end

    def resolve
      scope.none
    end
  end
end
