# app/controllers/parties/parties_controller.rb
class Parties::PartiesController < ApplicationController
  include Pagy::Backend

  before_action :set_party, only: %i[show update destroy]

  def index
    @q = params[:q].to_s.strip
    scope = policy_scope(Party).order(created_at: :desc)
    scope = scope.where("profile_number ILIKE ?", "%#{@q}%") if @q.present?
    @pagy, @parties = pagy(scope)
    respond_to do |fmt|
      fmt.html
      fmt.json { render json: { items: @parties.as_json, pagy: @pagy } }
    end
  end

  def show
    authorize @party
    respond_to do |fmt|
      fmt.html
      fmt.json { render json: @party }
    end
  end

  def create
    @party = Party.new(party_params)
    authorize @party
    if @party.save
      render json: @party, status: :created
    else
      render json: { errors: @party.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @party
    if @party.update(party_params)
      render json: @party
    else
      render json: { errors: @party.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @party
    @party.destroy
    head :no_content
  end

  private

  def set_party
    @party = Party.find(params[:id])
  end

  def party_params
    params.require(:party).permit(
      :relationship_to_institution_code,
      :withholding_option_code,
      :established_on
    )
  end
end
