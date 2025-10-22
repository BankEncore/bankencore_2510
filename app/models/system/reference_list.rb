class System::ReferenceList < ApplicationRecord
  self.table_name = "system_reference_lists"

  has_many :reference_values,
           class_name: "System::ReferenceValue",
           foreign_key: :reference_list_id,
           dependent: :restrict_with_exception

  validates :key, :name, :visibility, presence: true
  validates :key, uniqueness: true
  validates :visibility, inclusion: { in: %w[public internal private] }

  scope :publicly_visible, -> { where(visibility: "public") }

  def to_param = public_id
end
