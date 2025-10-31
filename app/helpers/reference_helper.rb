# app/helpers/reference_helper.rb
module ReferenceHelper
  # Fetch active (name, code) options for a reference list key
  def ref_options(key)
    list = System::ReferenceList.find_by(key: key)
    return [] unless list

    System::ReferenceValue
      .where(reference_list_id: list.id, active: true)
      .order(:sort_index, :name)
      .pluck(:name, :code)
  end

  # Countries: display full name, submit alpha2
  def country_options
    # Adjust attribute names if your model differs
    System::Country.order(:iso_short_name).pluck(:iso_short_name, :alpha2)
  end

  # Convenience wrappers with defaults
  def ref_select(f, method, list_key:, default: nil, include_blank: false, **html)
    selected = f.object.public_send(method).presence || default
    f.select method,
             options_for_select(ref_options(list_key), selected),
             { include_blank: include_blank },
             html
  end

  def country_select(f, method, default: nil, include_blank: true, **html)
    selected = f.object.public_send(method).presence || default
    f.select method,
             options_for_select(country_options, selected),
             { include_blank: include_blank },
             html
  end
end
