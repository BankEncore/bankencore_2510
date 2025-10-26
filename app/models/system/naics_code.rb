# app/models/system/naics_code.rb
class System::NaicsCode < ApplicationRecord
  self.table_name = "system_naics_codes"

  # presence
  validates :version, :code, :title, :level, presence: true
  # shape
  validates :code,  format: { with: /\A\d{2,6}\z/ }
  validates :level, inclusion: { in: [ 2, 3, 4, 5, 6 ] }
  # uniqueness per version
  validates :code, uniqueness: { scope: :version }

  scope :for_version, ->(v) { where(version: v) }
  scope :active,      ->(bool = true) { where(active: bool) }
  scope :sector,      ->(s) { where(sector: s) if s.present? }
  scope :roots,       ->     { where(level: 2) }
  scope :children_of, ->(c)  { where(parent_code: c) }

  belongs_to :parent,
            ->(rec) { where(version: rec.version) },
            class_name: "System::NaicsCode",
            primary_key: :code,
            foreign_key: :parent_code,
            optional: true

  has_many :children,
           ->(rec) { where(version: rec.version).order(:code) },
           class_name: "System::NaicsCode",
           primary_key: :code,
           foreign_key: :parent_code
end
