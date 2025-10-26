# app/controllers/admin/system/naics_codes_controller.rb
class Admin::System::NaicsCodesController < Admin::BaseController
  include Pagy::Backend

  def index
    authorize [ :admin, System::NaicsCode ]
    @version = params[:version]
    scope = policy_scope([ :admin, System::NaicsCode ]).for_version(@version)

    scope = scope.active(ActiveModel::Type::Boolean.new.cast(params[:active])) if params.key?(:active)
    scope = scope.sector(params[:sector])            if params[:sector].present?
    scope = scope.where(level: params[:level].to_i)  if params[:level].present?

    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where("code ILIKE ? OR title ILIKE ? OR description ILIKE ?", like, like, like)
    end

      scope = scope.order(:code)
      @pagy, @naics_codes = pagy(scope, items: (params[:items].presence || 50).to_i)
    end
end
