# app/controllers/system/reference_values_controller.rb
# new
class System::ReferenceValuesController < ApplicationController
  include Pagy::Backend
  before_action :set_list
  before_action :set_value, only: :show

  # GET /system/reference_lists/:key/reference_values
  # Filters: ?q=search&active=true
  def index
    scope = policy_scope(System::ReferenceValue)
              .where(reference_list_id: @list.id)
              .order(:sort_index, :code)

    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where("code ILIKE ? OR name ILIKE ? OR short_name ILIKE ? OR description ILIKE ?",
                          like, like, like, like)
    end
    unless params[:active].nil?
      scope = scope.where(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
    end

    @pagy, @reference_values = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /system/reference_lists/:key/reference_values/:code
  def show
    authorize @value
  end

  private

  def set_list
    raw = params[:reference_list_key] || params[:key]
    @list = System::ReferenceList.find_by!(key: raw.to_s)
    authorize @list, :show? # read-only policy should allow
    if raw != @list.key
      redirect_to system_reference_list_reference_values_path(@list.key), status: :moved_permanently and return
    end
  end

  def set_value
    code = params[:code].to_s
    @value = @list.reference_values.find_by!(code: code)
    if code != @value.code
      redirect_to system_reference_list_reference_value_path(@list.key, @value.code), status: :moved_permanently
    end
  end
end
