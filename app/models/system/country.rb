# app/models/system/country.rb
module System
  class Country < ApplicationRecord
    self.table_name = "system_countries"
  end
end

# app/models/system/region.rb
module System
  class Region < ApplicationRecord
    self.table_name = "system_regions"
    belongs_to :country, class_name: "System::Country", foreign_key: :system_country_id
  end
end
