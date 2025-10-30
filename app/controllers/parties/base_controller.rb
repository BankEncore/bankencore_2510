# app/controllers/parties/base_controller.rb
class Parties::BaseController < ApplicationController
  before_action :load_party, if: -> { params[:party_id].present? || params[:id].present? }

  rescue_from ActiveRecord::RecordNotUnique, PG::UniqueViolation do |e|
    handle_preferred_uniqueness(e)
  end

  private

  def load_party
    id = params[:party_id] || params[:id]
    @party = Parties::Party.find(id)
  end

  def preferred_alert_for(record)
    record.errors[:preferred].present? ? "Only one preferred record is allowed per party." :
                                         record.errors.full_messages.to_sentence
  end

  def handle_preferred_uniqueness(e)
    case e.message
    when /uq_names_one_preferred/i,
         /uq_phones_one_preferred/i,
         /uq_postal_addresses_one_preferred/i,
         /uq_email_addresses_one_preferred/i,
         /uq_web_addresses_one_preferred/i
      flash[:alert] = "Only one preferred record is allowed per party."
      redirect_back fallback_location: party_path(@party)
    else
      raise
    end
  end
end
