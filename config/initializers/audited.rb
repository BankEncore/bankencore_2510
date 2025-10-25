# config/initializers/audited.rb
# require "audited/active_record"   # ensures AR extension is loaded
Audited.current_user_method = :current_user
