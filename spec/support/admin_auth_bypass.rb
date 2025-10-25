# spec/support/admin_auth_bypass.rb
module AdminAuthBypass
  def bypass_admin_auth!
    # Devise auth guard
    if defined?(Devise)
      allow_any_instance_of(ApplicationController)
        .to receive(:authenticate_user!).and_return(true)
    end

    # Custom admin guard, if present on ApplicationController or subclasses
    if ApplicationController.method_defined?(:require_admin)
      allow_any_instance_of(ApplicationController)
        .to receive(:require_admin).and_return(true)
    end

    # Pundit: allow authorize and passthrough policy_scope
    if ApplicationController.method_defined?(:authorize)
      allow_any_instance_of(ApplicationController)
        .to receive(:authorize) { true }
    end
    if ApplicationController.method_defined?(:policy_scope)
      allow_any_instance_of(ApplicationController)
        .to receive(:policy_scope) { |_, scope| scope }
    end

    # Optional verify hooks
    %i[verify_authorized verify_policy_scoped].each do |m|
      if ApplicationController.method_defined?(m)
        allow_any_instance_of(ApplicationController).to receive(m).and_return(true)
      end
    end
  end
end

RSpec.configure do |c|
  c.include AdminAuthBypass, type: :request
end
