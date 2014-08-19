require 'nokogiri'
require 'active_support/core_ext/string/inflections'

module Aliyun
  module Mqs

    class Response

      def initialize(queue, response)
        @queue = queue
        @success = (response.code =~ /^20./) == 0
        if response.body
          begin
            xml_to_attribute(response.body)
          end
        end
      end

      def success?
        @success
      end

      def delete
        @queue.delete self
      end

      private

      def xml_to_attribute(xml)
        Nokogiri::XML(xml).root.children.each do |child|
          if child.element?
            name  = child.name.underscore
            value = child.content.to_s
            value = Time.at(value.to_f / 1000) if name.end_with?('_time')
            define_singleton_method name do
              instance_variable_get ('@' + name)
            end
            self.instance_variable_set('@' + name, value)
          end
        end
      end

    end

  end
end
