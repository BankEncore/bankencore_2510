# app/controllers/system/reference_lists_controller.rb
# new
class System::ReferenceListsController < ApplicationController
  include Pagy::Backend
  before_action :set_list, only: %i[show edit update destroy]

  # GET /system/reference_lists
  # Filters: ?q=time&active=true

  def index
    scope = policy_scope(System::ReferenceList).order(:key)

    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where("key ILIKE ? OR name ILIKE ? OR description ILIKE ?", like, like, like)
    end
    unless params[:active].nil?
      scope = scope.where(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
    end

    @pagy, @reference_lists = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /system/reference_lists/:key
  def show
    authorize @list
  end

  private

  def set_list
    raw = params[:key].to_s
    @list = System::ReferenceList.find_by!(key: raw)
    redirect_to system_reference_list_path(@list.key), status: :moved_permanently if raw != @list.key
  end
end
