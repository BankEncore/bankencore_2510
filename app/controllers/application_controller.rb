class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  include Pundit::Authorization
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError do
    respond_to do |fmt|
      fmt.html { render file: Rails.root.join("public/403.html"), status: :forbidden, layout: false }
      fmt.any  { head :forbidden }
    end
  end
end
