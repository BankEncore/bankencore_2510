# app/controllers/system/countries_controller.rb
class System::CountriesController < ApplicationController
  def index
    @countries = policy_scope(System::Country).where(active: true).order(:alpha2)
  end

  def show
    @country = System::Country.find_by!(alpha2: params[:alpha2].to_s.upcase)
    authorize @country
  end
end
