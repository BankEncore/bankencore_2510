# app/controllers/parties/parties_controller.rb
class Parties::PartiesController < ApplicationController
  include Pagy::Backend
  before_action :set_party, only: %i[show update destroy]

  def index
    authorize Parties::Party, :index?                       # <— add
    @q = params[:q].to_s.strip
    scope = policy_scope(Parties::Party).order(created_at: :desc)
    scope = scope.where("profile_number ILIKE ?", "%#{@q}%") if @q.present?
    @pagy, @parties = pagy(scope)

    respond_to do |fmt|
      fmt.html
      fmt.json { render json: { items: @parties.as_json, pagy: @pagy } }
      fmt.any  { head :not_acceptable }
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
    @party = Parties::Party.new(party_params)
    authorize @party
    if @party.save
      redirect_to party_path(@party), notice: "Party created"
    else
      render :new, status: :unprocessable_entity            # fix
    end
  end

  def update
    authorize @party
    if @party.update(party_params)
      redirect_to party_path(@party), notice: "Party updated"
    else
      render :edit, status: :unprocessable_entity           # fix
    end
  end

  def destroy
    authorize @party
    @party.destroy!
    redirect_to parties_path, notice: "Party deleted"
  end

  private

  def set_party
    @party = Parties::Party.find(params[:id])
  end

  def party_params
    params.require(:party)
          .permit(:relationship_to_institution_code, :withholding_option_code, :established_on)
  end
end
