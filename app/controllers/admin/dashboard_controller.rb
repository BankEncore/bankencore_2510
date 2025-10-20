# app/controllers/admin/dashboard_controller.rb
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
    end
  end
end
