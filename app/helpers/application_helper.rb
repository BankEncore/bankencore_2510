module ApplicationHelper
    include Pagy::Frontend
    def app_logo(**opts)
        svg = Rails.root.join("app/assets/images/logo.svg").read
        content_tag(:span, svg.html_safe, **opts)
    end
end
