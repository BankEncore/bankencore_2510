# frozen_string_literal: true

class SystemAdminPolicy < ApplicationPolicy
  def access? = user&.system_admin?
end
