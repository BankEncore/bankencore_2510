# app/policies/application_policy.rb
# new
class ApplicationPolicy
  attr_reader :user, :record
  def initialize(user, record) = (@user, @record = user, record)

  # Permission helper
  def can?(perm) = user&.can?(perm.to_s)

  # Default read for signed-out is allowed only where explicitly opened
  def index? = false
  def show?  = false
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false

  # Default scope denies unless overridden
  class Scope
    def initialize(user, scope) = (@user, @scope = user, scope)
    def resolve = @scope.none
  end
end
