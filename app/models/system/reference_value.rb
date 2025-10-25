# app/models/system/reference_value.rb
# new
module System
  class ReferenceValue < ApplicationRecord
    self.table_name = "system_reference_values"

    # Associations
    belongs_to :reference_list,
               class_name: "System::ReferenceList",
               foreign_key: :reference_list_id,
               inverse_of: :reference_values

    # Callbacks
    before_validation :normalize_fields

    # Validations
    validates :reference_list, presence: true

    CODE_FMT = /\A[a-z0-9._-]+\z/i.freeze
    validates :code,
      presence: true,
      length: { maximum: 100 },
      format: { with: CODE_FMT, message: "allows letters, numbers, dot, underscore, hyphen" },
      uniqueness: { scope: :reference_list_id, case_sensitive: false }

    validates :name, presence: true, length: { maximum: 200 }
    validates :short_name, length: { maximum: 100 }, allow_blank: true

    validates :sort_index, presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }

    validates :active, inclusion: { in: [ true, false ] }

    validate :metadata_is_object
    validate :validity_window_order

    # Scopes
    scope :active, -> { where(active: true) }
    scope :by_code, ->(c) { where(code: c.to_s) }
    scope :search, ->(q) do
      q = q.to_s.strip
      q.blank? ? all :
        where("code ILIKE :q OR name ILIKE :q OR short_name ILIKE :q OR description ILIKE :q", q: "%#{q}%")
    end
    scope :ordered, -> { order(:sort_index, :code) }

    # Routing (nested under list by :code)
    def to_param = code

    private

    def normalize_fields
      self.code = code.to_s.strip
      self.short_name = short_name.to_s.strip.presence
      self.name = name.to_s.strip
      self.external_code = external_code.to_s.strip.presence
      # ensure jsonb columns are objects
      self.metadata = {} unless metadata.is_a?(Hash)
    end

    def metadata_is_object
      errors.add(:metadata, "must be an object") unless metadata.is_a?(Hash)
    end

    def validity_window_order
      return if valid_from.blank? || valid_to.blank?
      errors.add(:valid_to, "must be on or after valid_from") if valid_to < valid_from
    end
  end
end
