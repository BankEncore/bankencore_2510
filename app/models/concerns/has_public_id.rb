# app/models/concerns/has_public_id.rb
module HasPublicId
  extend ActiveSupport::Concern
  included do
    def to_param = public_id # ensures URL uses public_id
    validates :public_id, presence: true, uniqueness: true
  end
end
