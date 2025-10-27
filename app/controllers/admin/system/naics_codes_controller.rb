# app/controllers/admin/system/naics_codes_controller.rb
class Admin::System::NaicsCodesController < Admin::BaseController
  include Pagy::Backend

  def index
    authorize [ :admin, System::NaicsCode ]
    @version = params[:version].presence

    scope = Admin::System::NaicsCodePolicy::Scope.new(current_user, System::NaicsCode).resolve
    scope = scope.for_version(@version) if @version

    scope = scope.active(ActiveModel::Type::Boolean.new.cast(params[:active])) if params.key?(:active)
    scope = scope.sector(params[:sector])            if params[:sector].present?
    scope = scope.where(level: params[:level].to_i)  if params[:level].present?
    scope = scope.where("code ILIKE :q OR title ILIKE :q OR description ILIKE :q", q: "%#{params[:q].to_s.strip}%") if params[:q].present?

    @pagy, @naics_codes = pagy(scope.order(:code), items: (params[:items].presence || 50).to_i)
  end

  def show
    authorize [ :admin, System::NaicsCode ]
    @version = params[:version].presence
    scope = Admin::System::NaicsCodePolicy::Scope.new(current_user, System::NaicsCode).resolve
    scope = scope.for_version(@version) if @version
    render json: scope.find_by!(code: params[:code])
  end
end
