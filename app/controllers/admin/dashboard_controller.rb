# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < Admin::BaseController
    def index
      @counts = {
        ach_routings:       ::Payments::AchRouting.count,
        country_currencies: ::System::CountryCurrency.count,
        naics_codes:        ::System::NaicsCode.count,
        reference_lists:    ::System::ReferenceList.count,
        reference_values:   ::System::ReferenceValue.count,
        users:              ::User.count,
        branches:           ::Branch.count
      }

      @latest_naics_version = ::System::NaicsCode.order(version: :desc).limit(1).pick(:version)
      @can_view_naics       = policy([:admin, ::System::NaicsCode]).index? rescue false
      #                               ^^^^^^^^ use the model under System, not Admin::System
    end
  end
end
