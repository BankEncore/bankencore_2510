# app/models/concerns/reference_code_validator.rb
class ReferenceCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    return if value.blank?
    list_key = options.fetch(:list) # e.g., "parties.genders"
    # Fail-open if lists not seeded yet.
    list = System::ReferenceList.find_by(key: list_key) or return
    codes = Rails.cache.fetch([ "ref", list_key, "codes", list.updated_at.to_i ], expires_in: 10.minutes) do
      list.values.where(active: true).pluck(:code)
    end
    record.errors.add(attr, "is not in #{list_key}") unless codes.include?(value)
  end
end
