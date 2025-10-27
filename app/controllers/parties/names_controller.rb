# app/controllers/parties/names_controller.rb
class Parties::NamesController < ApplicationController
  before_action :set_party
  before_action :set_name, only: %i[show update destroy]

  def index
    authorize @party, :show?
    @names = @party.names.order(preferred: :desc, created_at: :asc)
    respond_to do |fmt|
      fmt.html
      fmt.json { render json: @names }
    end
  end

  def show
    authorize @name
    render json: @name
  end

  def create
    @name = @party.names.build(name_params)
    authorize @name
    if @name.save
      render json: @name, status: :created
    else
      render json: { errors: @name.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @name
    if @name.update(name_params)
      render json: @name
    else
      render json: { errors: @name.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @name
    @name.destroy
    head :no_content
  end

  private

  def set_party
    @party = Party.find(params[:party_id])
  end

  def set_name
    @name = @party.names.find(params[:id])
  end

  def name_params
    params.require(:parties_name).permit(
      :name_type_code, :full_name, :family_name, :given_name, :middle_name,
      :prefix_code, :suffix_code, :preferred, :valid_from, :valid_to
    )
  end
end
