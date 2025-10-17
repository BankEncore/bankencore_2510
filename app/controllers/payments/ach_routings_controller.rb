# app/controllers/payments/ach_routings_controller.rb
module Payments
  class AchRoutingsController < ApplicationController
    def index
      @routings = AchRouting.active_view
                            .q(params[:q])
                            .state(params[:state])
                            .order(:routing_number)
                            .limit(limit)
                            .offset(offset)

      respond_to do |format|
        format.html # renders views/payments/ach_routings/index.html.erb
        format.json { render json: @routings.as_json(only: %i[public_id routing_number customer_name state_code city]) }
      end
    end

    def show
      @routing = AchRouting.find_by!(public_id: params[:public_id])
      respond_to do |format|
        format.html # renders views/payments/ach_routings/show.html.erb
        format.json { render json: @routing.as_json }
      end
    end

    private

    def limit   = [ [ params.fetch(:limit, 50).to_i, 1 ].max, 200 ].min
    def offset  = [ params.fetch(:offset, 0).to_i, 0 ].max
  end
end
