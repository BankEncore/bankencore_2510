# app/controllers/system/regions_controller.rb
# new
class System::RegionsController < ApplicationController
  include Pagy::Backend
  before_action :set_region, only: :show

  # GET /system/regions
  # Filters: ?country_alpha2=US&kind=state&q=pa
  def index
    scope = policy_scope(System::Region).where(active: true).order(:country_alpha2, :region_code)

    if (ca = params[:country_alpha2].to_s.upcase.presence)
      scope = scope.where(country_alpha2: ca)
    end
    if (k = params[:kind].to_s.strip.presence)
      scope = scope.where(kind: k)
    end
    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where("region_code ILIKE ? OR name ILIKE ? OR iso_code ILIKE ?", like, like, like)
    end

    @pagy, @regions = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /system/regions/:iso_code (e.g., US-PA)
  def show
    authorize @region
  end

  private

  def set_region
    iso = params[:iso_code].to_s.upcase
    @region = System::Region.find_by!(iso_code: iso)
    redirect_to system_region_path(@region.iso_code), status: :moved_permanently if params[:iso_code] != @region.iso_code
  end
end
