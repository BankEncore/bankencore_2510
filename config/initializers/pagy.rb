# config/initializers/pagy.rb
require "pagy/extras/overflow"   # nicer overflow behavior
Pagy::DEFAULT[:items] = 50
Pagy::DEFAULT[:overflow] = :last_page
