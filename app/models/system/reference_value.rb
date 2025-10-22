class System::ReferenceValue < ApplicationRecord
  self.table_name = "system_reference_values"

  belongs_to :reference_list, class_name: "System::ReferenceList"
  belongs_to :parent, class_name: "System::ReferenceValue", optional: true
  has_many   :children, class_name: "System::ReferenceValue", foreign_key: :parent_id

  validates :key, :label, presence: true
  validates :position, numericality: { only_integer: true }
  validates :active, inclusion: { in: [ true, false ] }

  scope :ordered, -> { order(:position, :label) }
  scope :active,  -> { where(active: true) }

  # Optional: per-list metadata checks (expand as needed)
  validate :metadata_contract
  def metadata_contract
    case reference_list&.key
    when "relationship_types"
      %w[direction inverse_code inverse_name inverse_description].each do |k|
        errors.add(:metadata, "#{k} required") if metadata[k].to_s.empty?
      end
    when "identity_types"
      ok = %w[low medium high]
      errors.add(:metadata, "assurance invalid") unless ok.include?(metadata["assurance"].to_s)
    end
  end

  def to_param = public_id
end
