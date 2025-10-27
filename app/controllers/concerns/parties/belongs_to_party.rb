# app/controllers/concerns/parties/belongs_to_party.rb
module Parties::BelongsToParty
  extend ActiveSupport::Concern
  included do
    before_action :set_party
  end
  private
  def set_party = @party = Party.find(params[:party_id])
end
