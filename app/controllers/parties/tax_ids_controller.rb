# app/controllers/parties/tax_ids_controller.rb
class Parties::TaxIdsController < ApplicationController
  before_action :set_party
  before_action :set_tax, only: %i[show edit update destroy]

  # If you enable these globally, keep them here too for clarity
  after_action :verify_authorized,       except: %i[index]
  after_action :verify_policy_scoped,    only:   %i[index]

  def index
    @tax_ids = policy_scope(@party.tax_ids)   # ← satisfies PolicyScopingNotPerformed
    render :index
  end

  def new
    @tax = @party.tax_ids.build
    authorize @tax                             # ← satisfies AuthorizationNotPerformed
    render :new
  end

  def show
    authorize @tax
    render :show
  end

  def edit
    authorize @tax
    render :edit
  end

  private

  def set_party
    @party = Parties::Party.find(params[:party_id])
  end

  def set_tax
    @tax = @party.tax_ids.find(params[:id])
  end
end
