# app/controllers/admin/payments/ach_routings_controller.rb
# new
module Admin
  module Payments
    class AchRoutingsController < Admin::BaseController
      before_action :load_frb_options, only: %i[new edit create update]
      include Pagy::Backend

      def index
        redirect_to payments_ach_routings_path
      end

      def show
        redirect_to payments_ach_routing_path(find_record.public_id)
      end
      def new    = @ach_routing = ::Payments::AchRouting.new
      def edit   = @ach_routing = find_record

      def create
        @ach_routing = ::Payments::AchRouting.new(permitted)
        if @ach_routing.save
          redirect_to admin_payments_ach_routing_path(@ach_routing), notice: "Saved"
        else
          load_frb_options
          render :new, status: :unprocessable_entity
        end
      end

      def update
        @ach_routing = find_record
        if @ach_routing.update(permitted)
          redirect_to admin_payments_ach_routing_path(@ach_routing), notice: "Updated"
        else
          load_frb_options
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        find_record.destroy!
        redirect_to admin_payments_ach_routings_path, notice: "Deleted"
      end

      private

      def find_record = ::Payments::AchRouting.find_by!(public_id: params[:public_id])

      def permitted
        params.require(:payments_ach_routing).permit(:routing_number, :new_routing_number, :customer_name,
          :address, :city, :state_code, :zip_code, :phone_number, :servicing_frb_number, :notes,
          :us_treasury, :us_postal_service, :federal_reserve_bank, :on_us, :special_handling, :office_code)
      end

      def load_frb_options
        data = ::Payments::FrbDirectory::DATA.values
        @frb_options = data.map { |b| [ "#{b.city} (#{b.district}) — #{b.rtn}", b.rtn ] }
      end
    end
  end
end
