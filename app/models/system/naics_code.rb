# app/models/system/naics_code.rb
# new
module System
  class NaicsCode < ApplicationRecord
    self.table_name = "system_naics_codes"

    # ---------- Constants ----------
    CODE_RE    = /\A\d{2,6}\z/
    VERSION_RE = /\A20\d{2}\z/
    LEVEL_RANGE = 1..6

    # ---------- Callbacks ----------
    before_validation :normalize_fields
    before_validation :derive_sector

    # ---------- Validations ----------
    validates :version, presence: true, format: { with: VERSION_RE }
    validates :code,    presence: true, format: { with: CODE_RE }
    validates :title,   presence: true
    validates :level,   presence: true, numericality: { only_integer: true }, inclusion: { in: LEVEL_RANGE }
    validates :sector,  allow_nil: true, format: { with: /\A\d{2}\z/ }
    validates :active,  inclusion: { in: [ true, false ] }

    validates :code, uniqueness: { scope: :version, case_sensitive: true }

    validate :parent_within_same_version
    validate :parent_shorter_than_code
    validate :level_consistent_with_code_length

    # ---------- Scopes ----------
    scope :for_version, ->(v) { where(version: v) }
    scope :by_code,     ->     { order(:code) }
    scope :active,      ->     { where(active: true) }
    scope :at_level,    ->(n)  { where(level: n) }
    scope :sector_eq,   ->(s)  { where(sector: s.to_s.first(2)) }

    # ---------- Routing ----------
    # Public routes include version in the path; to_param stays as code.
    def to_param = code

    # ---------- Hierarchy helpers ----------
    def parent
      return nil if parent_code.blank?
      self.class.find_by(version: version, code: parent_code)
    end

    def children
      self.class.where(version: version, parent_code: code).by_code
    end

    def root?  = parent_code.blank?
    def leaf?  = !self.class.exists?(version: version, parent_code: code)

    def ancestors
      list, node = [], self
      while (p = node.parent)
        list.unshift(p)
        node = p
      end
      list
    end

    # ---------- Private ----------
    private

    def normalize_fields
      self.version     = version.to_s.strip
      self.code        = code.to_s.strip
      self.parent_code = parent_code.to_s.strip.presence
      self.title       = title.to_s.strip
      self.sector      = sector.to_s.strip.presence
      self.active      = !!active
    end

    def derive_sector
      return if code.blank?
      self.sector = code[0, 2]
    end

    def parent_within_same_version
      return if parent_code.blank?
      unless self.class.exists?(version: version, code: parent_code)
        errors.add(:parent_code, "must reference an existing code in the same version")
      end
    end

    def parent_shorter_than_code
      return if parent_code.blank?
      if parent_code.length >= code.length
        errors.add(:parent_code, "must be shorter than code")
      end
    end

    def level_consistent_with_code_length
      return if code.blank? || level.blank?
      # Typical NAICS convention: 2..6 digits; deeper levels have longer codes.
      expected = code.length
      if level != expected && !(level == 1 && code.length == 2)
        # Allow level 1 for sector summaries that still store "2-digit" code.
        errors.add(:level, "should match code length (2..6), or 1 for sector summaries")
      end
    end
  end
end
