require 'aliyun/mqs/version'
require 'aliyun/mqs/queue'
require 'aliyun/mqs/response'
require 'aliyun/mqs/configuration'
require 'aliyun/mqs/http'

module Aliyun
  module Mqs

    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    def self.get(name,  access_owner_id: nil)
      Aliyun::Mqs::Queue.new(name, access_owner_id: access_owner_id)
    end

  end
end
