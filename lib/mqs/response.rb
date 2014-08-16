require 'nokogiri'
require 'active_support/core_ext/string/inflections'

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
          define_singleton_method child.name.underscore do
            instance_variable_get ('@' + child.name.underscore)
          end
          self.instance_variable_set('@' + child.name.underscore, child.content.to_s)
        end
      end
    end

  end

end
