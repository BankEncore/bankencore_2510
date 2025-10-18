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

    def new
      @routing = Payments::AchRouting.new
      build_form_options
    end

    def create
      @routing = Payments::AchRouting.new(routing_params)
      if @routing.save
        redirect_to payments_ach_routing_path(@routing), notice: "Saved"
      else
        build_form_options
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @routing = Payments::AchRouting.find_by!(public_id: params[:public_id])
      build_form_options
    end

    def update
      @routing = Payments::AchRouting.find_by!(public_id: params[:public_id])
      if @routing.update(routing_params)
        redirect_to payments_ach_routing_path(@routing), notice: "Updated"
      else
        build_form_options
        render :edit, status: :unprocessable_entity
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

    def build_form_options
    @frb_options = Payments::FrbDirectory::DATA.values.map { |b| [ "#{b.city} (#{b.district}) — #{b.rtn}", b.rtn ] }
    end

    def routing_params
      params.require(:payments_ach_routing).permit(
        :routing_number, :new_routing_number, :customer_name,
        :address, :city, :state_code, :zip_code, :phone_number,
        :servicing_frb_number, :notes,
        :us_treasury, :us_postal_service, :federal_reserve_bank, :on_us, :special_handling
      )
    end

      private
    def routing_params
      p = params.require(:payments_ach_routing).permit(:routing_number, :new_routing_number, :customer_name,
        :address, :city, :state_code, :zip_code, :phone_number, :servicing_frb_number, :notes,
        :us_treasury, :us_postal_service, :federal_reserve_bank, :on_us, :special_handling, :office_code)
      p[:new_routing_number]   = "000000000" if p[:new_routing_number].blank?
      p[:routing_number]       = p[:routing_number].to_s.rjust(9, "0") if p[:routing_number].present?
      p[:servicing_frb_number] = p[:servicing_frb_number].to_s.rjust(9, "0") if p[:servicing_frb_number].present?
      p[:phone_number]         = p[:phone_number].to_s.gsub(/\D/, "")
      p[:phone_number]         = "0000000000" if p[:phone_number].blank?
      p
    end

    def apply_defaults
      self.routing_number       = routing_number.to_s.rjust(9, "0") if routing_number.present?
      self.new_routing_number   = "000000000"                       if new_routing_number.blank?
      self.servicing_frb_number = servicing_frb_number.to_s.rjust(9, "0") if servicing_frb_number.present?
      self.office_code          = normalize_office_code(office_code)

      # phone: keep digits only; default to 10 zeros to satisfy CHECK
      if phone_number.present?
        self.phone_number = phone_number.to_s.gsub(/\D/, "")
      end
      self.phone_number = "0000000000" if phone_number.blank?

      self.record_type_code        ||= "0"
      self.institution_status_code ||= "1"
      self.data_view_code          ||= "1"
    end

    def normalize_office_code(v)
      x = v.to_s.strip.upcase
      return "B" if x == "1" || x == "B"
      "O"
    end
  end
end
