# spec/support/assets_stub.rb
RSpec.configure do |config|
  config.before(:suite) do
    path = Rails.root.join("app/assets/builds/tailwind.css")
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "/* stub for CI */") unless File.exist?(path)
  end
end