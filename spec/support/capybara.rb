# spec/support/capybara.rb
require "capybara/rspec"
require "selenium-webdriver"

Capybara.default_max_wait_time = 5

Capybara.register_driver :chrome_headless_safe do |app|
  opts = Selenium::WebDriver::Chrome::Options.new
  opts.add_argument "--headless=new"
  opts.add_argument "--disable-gpu"
  opts.add_argument "--no-sandbox"
  opts.add_argument "--disable-dev-shm-usage"
  opts.add_argument "--window-size=1400,1400"
  opts.add_argument "--remote-debugging-port=0"
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: opts)
end

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :rack_test }         # default: no JS
  config.before(:each, type: :system, js: true) { driven_by :chrome_headless_safe } # opt-in
end
