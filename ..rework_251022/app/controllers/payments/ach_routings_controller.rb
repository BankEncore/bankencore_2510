# app/controllers/payments/ach_routings_controller.rb
# new
class Payments::AchRoutingsController < ApplicationController
  include Pagy::Backend
  before_action :set_row, only: :show

  # GET /payments/ach_routings
  # Filters:
  #   q=term                 # routing_number, name, city, state
  #   state=PA               # 2-letter
  #   office=O               # 1 char
  #   type=0                 # record_type_code
  #   status=1               # institution_status_code
  #   view=1                 # data_view_code
  #   items=50               # per-page
  def index
    authorize Payments::AchRouting

    scope = policy_scope(Payments::AchRouting).order(:routing_number)

    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where(
        "routing_number ILIKE ? OR customer_name ILIKE ? OR city ILIKE ? OR state_code ILIKE ?",
        like, like, like, like
      )
    end
    scope = scope.where(state_code: params[:state].to_s.upcase) if params[:state].present?
    scope = scope.where(office_code: params[:office].to_s[0])   if params[:office].present?
    scope = scope.where(record_type_code: params[:type].to_s[0]) if params[:type].present?
    scope = scope.where(institution_status_code: params[:status].to_s[0]) if params[:status].present?
    scope = scope.where(data_view_code: params[:view].to_s[0]) if params[:view].present?

    @pagy, @ach_routings = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /payments/ach_routings/:public_id
  def show
    authorize @ach_routing
  end

  private

  def set_row
    pid = params[:public_id].to_s
    @ach_routing = Payments::AchRouting.find_by!(public_id: pid)
    # canonicalize if param differs from stored UUID
    if pid != @ach_routing.public_id
      redirect_to payments_ach_routing_path(@ach_routing.public_id), status: :moved_permanently
    end
  end
end
