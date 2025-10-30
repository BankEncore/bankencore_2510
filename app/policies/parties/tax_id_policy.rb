# app/policies/parties/tax_id_policy.rb
class Parties::TaxIdPolicy < Parties::BaseChildPolicy
  class Scope < Scope
    def resolve = scope # refine as needed
  end

  def index?  = true
  def show?   = true
  def new?    = create?
  def edit?   = update?
  def create? = true
  def update? = true
  def destroy? = true
end
