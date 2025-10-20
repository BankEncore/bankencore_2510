# app/helpers/ui_helper.rb
module UiHelper
  def btn(label, href = nil, variant: "primary", size: "md", **opts, &)
    klass = "btn btn-#{variant} btn-#{size}"
    href ? link_to(label, href, { class: klass }.merge(opts)) :
           content_tag(:button, label, { class: klass, type: "submit" }.merge(opts))
  end
end
