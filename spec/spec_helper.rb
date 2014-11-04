require 'rspec'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'aliyun/mqs'

Dir[File.join(File.dirname(__FILE__), "../spec/support/**/*.rb")].sort.each {|f| require f}
RSpec.configure do |config|
  config.color = true
  config.mock_with :rspec
end

Aliyun::Mqs.configure do |config|
  config.access_id = 'access-id'
  config.key = "key"
  config.region = 'region'
  config.owner_id = 'owner-id'
end