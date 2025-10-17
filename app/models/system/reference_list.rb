# app/models/system/reference_list.rb
class System::ReferenceList < ApplicationRecord
  has_many :reference_values, class_name: "System::ReferenceValue", dependent: :destroy, inverse_of: :reference_list

  validates :name, presence: true
  validates :public_id, presence: true, uniqueness: true
  before_validation :ensure_public_id

  def to_param = public_id
  private
  def ensure_public_id = self.public_id ||= SecureRandom.uuid
end
