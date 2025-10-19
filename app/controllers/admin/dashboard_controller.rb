# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < BaseController
    def index
      @counts = {
        reference_lists: System::ReferenceList.count,
        reference_values: System::ReferenceValue.count,
        ach_routings:     Payments::AchRouting.count,
        country_currencies:  System::CountryCurrency.count,
        naics_codes:        System::NaicsCode.count
      }
    end
  end
end
