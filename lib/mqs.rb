require 'mqs/version'
require 'mqs/queue'
require 'mqs/response'
require 'mqs/configuration'

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

end
