# app/models/system/reference_value.rb
class System::ReferenceValue < ApplicationRecord
  belongs_to :reference_list, class_name: "System::ReferenceList", foreign_key: :reference_list_id

  # ensure polymorphic routing uses reference_values
  def self.model_name = ActiveModel::Name.new(self, nil, "ReferenceValue")

  validates :key, :label, presence: true
  validates :public_id, presence: true, uniqueness: true
  before_validation :ensure_public_id

  def to_param = public_id

  private
  def ensure_public_id = self.public_id ||= SecureRandom.uuid
end
