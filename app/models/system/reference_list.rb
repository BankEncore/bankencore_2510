# app/models/system/reference_list.rb
# new
module System
  class ReferenceList < ApplicationRecord
    self.table_name = "system_reference_lists"

    has_many :reference_values,
             class_name: "System::ReferenceValue",
             foreign_key: :reference_list_id,
             inverse_of: :reference_list,
             dependent: :restrict_with_exception

    # ---------- Callbacks ----------
    before_validation :normalize_key

    # ---------- Validations ----------
    validates :key,
      presence: true,
      uniqueness: { case_sensitive: false },
      length: { maximum: 100 },
      format: { with: /\A[a-z0-9._-]+\z/, message: "allows a-z, 0-9, dot, underscore, hyphen" }

    validates :name,
      presence: true,
      length: { maximum: 200 }

    validates :active, inclusion: { in: [ true, false ] }

    # metadata is jsonb; ensure hash
    if column_names.include?("metadata")
      validate do
        value = self[:metadata]
        self[:metadata] = {} if value.nil?
        errors.add(:metadata, "must be an object") unless self[:metadata].is_a?(Hash)
      end
    end

    # ---------- Scopes ----------
    scope :active,  -> { where(active: true) }
    scope :by_key,  ->(k) { where(key: k.to_s.downcase) }
    scope :search,  ->(q) {
      q = q.to_s.strip
      q.blank? ? all :
        where("key ILIKE :q OR name ILIKE :q OR description ILIKE :q", q: "%#{q}%")
    }

    # ---------- Routing ----------
    def to_param = key

    # ---------- Helpers ----------
    def value(code)
      reference_values.find_by(code: code.to_s)
    end

    private

    def normalize_key
      return if key.blank?
      self.key = key.to_s.strip.downcase.gsub(/[^a-z0-9._-]/, "-").gsub(/-+/, "-")
    end
  end
end
