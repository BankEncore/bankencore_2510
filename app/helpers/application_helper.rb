module ApplicationHelper
    include Pagy::Frontend
    def app_logo(**opts)
        svg = Rails.root.join("app/assets/images/logo.svg").read
        content_tag(:span, svg.html_safe, **opts)
    end

    def inline_svg(filename, **attrs)
        path = Rails.root.join("app/assets/images", filename)
        svg  = File.read(path)
        if attrs.any?
        injected = attrs.map { |k, v| %(#{k.to_s.dasherize}="#{ERB::Util.html_escape(v)}") }.join(" ")
        svg.sub!("<svg", "<svg #{injected}")
        end
        svg.html_safe
    end
end
