# app/controllers/system/naics_codes_controller.rb
module System
  class NaicsCodesController < ApplicationController
    include Pagy::Backend
    before_action :load_version
    before_action :set_naics, only: :show

    def index
      authorize System::NaicsCode
      scope = policy_scope(System::NaicsCode).where(version: @version).order(:code)
      if (q = params[:q].to_s.strip.presence)
        like = "%#{q}%"
        scope = scope.where("code ILIKE ? OR title ILIKE ?", like, like)
      end
      @pagy, @naics_codes = pagy(scope, items: (params[:items].presence || 50).to_i)
    end

    def show
      authorize @naics
      @ancestors = []
      node = @naics
      while node&.parent_code.present?
        parent = System::NaicsCode.find_by(version: node.version, code: node.parent_code)
        break unless parent
        @ancestors.unshift(parent)
        node = parent
      end
    end

    private

    def load_version
      @version = params[:version].to_s.presence
    end

    def set_naics
      code = params[:code].to_s.strip
      @naics = System::NaicsCode.find_by!(version: @version, code: code)
      if params[:code] != @naics.code
        redirect_to system_naics_code_path(version: @naics.version, code: @naics.code), status: :moved_permanently
      end
    end
  end
end
