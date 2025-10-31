# app/lib/ref.rb
module Ref
  module_function

  def list(key)
    System::ReferenceList.find_by!(key: key)
  end

  def options(key)
    System::ReferenceValue
      .where(reference_list_id: list(key).id, active: true)
      .order(:sort_index, :name)
      .pluck(:name, :code)
  end

  def codes(key)
    System::ReferenceValue
      .where(reference_list_id: list(key).id, active: true)
      .order(:sort_index, :name)
      .pluck(:code)
  end

  def value(key, code)
    System::ReferenceValue.find_by(reference_list_id: list(key).id, code: code)
  end

  def meta(key, code)
    value(key, code)&.metadata || {}
  end
end
