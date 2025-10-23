# app/controllers/admin/dashboard_controller.rb
# new
module Admin
  class Admin::DashboardController < Admin::BaseController
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
      # Latest NAICS version for links that require a version param
      @latest_naics_version = ::System::NaicsCode.distinct.order(version: :desc).limit(1).pluck(:version).first
    end
  end
end
