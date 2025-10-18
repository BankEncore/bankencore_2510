# app/models/concerns/has_public_id.rb
module HasPublicId
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_public_id
    validates :public_id, presence: true, uniqueness: true
  end

  private

  def ensure_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
