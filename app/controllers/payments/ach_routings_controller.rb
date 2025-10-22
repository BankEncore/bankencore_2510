# app/controllers/payments/ach_routings_controller.rb
module Payments
  class AchRoutingsController < ApplicationController
    include Pagy::Backend
    helper Payments::AchRoutingsHelper

    def index
      @q      = params[:q].to_s.strip
      @state  = params[:state].presence
      @states = Payments::AchRouting.distinct.order(:state_code).pluck(:state_code)

      scope = Payments::AchRouting.order(:routing_number)
      scope = scope.where("routing_number ILIKE :q OR customer_name ILIKE :q", q: "%#{@q}%") if @q.present?
      scope = scope.where(state_code: @state) if @state

      @pagy, @ach_routings = pagy(scope, items: (params[:items].presence || 50).to_i)
    end

    def show
      @ach_routing =
        Payments::AchRouting.find_by!(public_id: params[:public_id] || params[:id])

      respond_to do |format|
        format.html
        format.json { render json: @ach_routing.as_json }
      end
    end

    # /payments/ach_routings/:id where :id was legacy numeric
    def legacy_redirect
      record = Payments::AchRouting.find(params[:id])
      redirect_to payments_ach_routing_path(record.public_id), status: :moved_permanently
    end
  end
end
