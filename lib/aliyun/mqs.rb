require 'active_support/core_ext'
require 'rest-client'
require 'nokogiri'
require 'yaml'
require 'aliyun/mqs/version'
# RestClient.log=STDOUT

# Monkey patch hash to support xml array and xml object
class Hash
  def self.xml_array content, *path
    o = xml_object(content, *path)
    return (o.is_a?(Array) ? o : [o]).reject{|n| n.empty?}
  end

  def self.xml_object content, *path
    h = from_xml(content)
    path.reduce(h){|memo, node|  memo = memo[node] || {}}
  end
end

module Aliyun
  module Mqs
    require 'aliyun/mqs/queue'
    require 'aliyun/mqs/message'
    require 'aliyun/mqs/request'
    require 'aliyun/mqs/cli'

    class << self
      def configuration
        @configuration ||=  begin
          if defined? Rails
            config_file = Rails.root.join("config/aliyun-mqs.yml")
          else
            config_file = File.expand_path("~/.aliyun-mqs.yml")
          end

          if (File.exist?(config_file))
            config = YAML.load(ERB.new(File.new(config_file).read).result)
            config = config[Rails.env] if defined? Rails
          end
          OpenStruct.new(config || {access_id:"", key:"", region:"", owner_id:""})
        end
      end

      def configure
        yield(configuration)
      end
    end

  end
end
