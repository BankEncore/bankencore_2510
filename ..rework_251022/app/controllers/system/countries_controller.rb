# app/controllers/system/countries_controller.rb
# new
class System::CountriesController < ApplicationController
  def index
    @countries = policy_scope(System::Country).where(active: true)
  end
  def show
    @country = System::Country.find_by!(alpha2: params[:alpha2].upcase)
    authorize @country
  end
end
