# app/controllers/admin/payments/ach_routings_controller.rb
# new
module Admin
  module Payments
    class AchRoutingsController < Admin::BaseController
      before_action :load_frb_options, only: %i[new edit create update]
      include Pagy::Backend

      def index
        authorize [ :admin, ::Payments::AchRouting ], :index?

        @q      = params[:q].to_s.strip
        @active = ActiveModel::Type::Boolean.new.cast(params[:active])
        @state  = params[:state].presence

        scope = policy_scope([ :admin, ::Payments::AchRouting ])
        scope = scope.where("routing_number ILIKE :q OR customer_name ILIKE :q", q: "%#{@q}%") if @q.present?
        scope = scope.where(active: @active) if params.key?(:active)
        scope = scope.where(state_code: @state) if @state.present?

        # Provide the list the borrowed view expects
        @states = policy_scope([ :admin, ::Payments::AchRouting ])
                    .distinct.order(:state_code).pluck(:state_code).compact

        @pagy, @ach_routings = pagy(scope.order(:routing_number), items: (params[:items].presence || 50).to_i)

        # render the non-admin template and pass the search path it should use
        render template: "payments/ach_routings/index",
              locals: { search_path: admin_payments_ach_routings_path }
      end


      def show
        scope  = policy_scope([ :admin, ::Payments::AchRouting ])
        @ach_routing = scope.find(params[:id])
        authorize [ :admin, @ach_routing ], :show?
        render template: "payments/ach_routings/show"
      end

      def new    = @ach_routing = ::Payments::AchRouting.new
      def edit   = @ach_routing = find_record

      def create
        @ach_routing = ::Payments::AchRouting.new(permitted)
        if @ach_routing.save
          redirect_to admin_payments_ach_routing_path(@ach_routing), notice: "Saved"
        else
          load_frb_options
          render :new, status: :unprocessable_content
        end
      end

      def update
        @ach_routing = find_record
        if @ach_routing.update(permitted)
          redirect_to admin_payments_ach_routing_path(@ach_routing), notice: "Updated"
        else
          load_frb_options
          render :edit, status: :unprocessable_content
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
