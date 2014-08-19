require 'active_support/core_ext/hash'
require 'builder'
require 'aliyun/mqs/http'

module Aliyun
  module Mqs

    class Queue
      include Mqs::Http

      def initialize(name, access_owner_id: nil)
        @access_key_id     = Mqs.configuration.access_key_id
        @access_key_secret = Mqs.configuration.access_key_secret
        @access_region     = Mqs.configuration.access_region
        @access_owner_id   = access_owner_id || Mqs.configuration.access_owner_id
        @access_queue = name
        @access_host  = "#{@access_owner_id}.mqs-#{@access_region}.aliyuncs.com"
        throw '参数不能为nil' if instance_variables.any? {|x| x == nil}
      end


      def destroy
        verb = 'DELETE'
        request_resource = "/#{@access_queue}"
        request_uri = "http://#{@access_host}#{request_resource}"
        send_request(verb, request_uri)
      end

      def send(message_body, delay_seconds: 0, priority: 8)
        verb = 'POST'
        content_body = to_xml(message_body, delay_seconds, priority)
        request_resource = "/#{@access_queue}/messages"
        request_uri = "http://#{@access_host}#{request_resource}"
        send_request(verb, request_uri, content_body)
      end

      def receive(waitseconds: nil, peekonly: false)
        verb = 'GET'
        query_params = {}
        query_params[:waitseconds] = waitseconds if waitseconds
        query_params[:peekonly] = true if peekonly # Aliyun doesn't accept uncessary query params
        request_resource =  "/#{@access_queue}/messages" + (query_params.length > 0 ? '?' + query_params.to_param : '')
        request_uri      = "http://#{@access_host}#{request_resource}"
        send_request(verb, request_uri)
      end

      def delete message
        verb = 'DELETE'
        if String === message
          receipt_handle = message
        elsif Response === message
          receipt_handle = message.receipt_handle
        end
        request_resource = "/#{@access_queue}/messages?" + {ReceiptHandle: receipt_handle}.to_param
        request_uri = "http://#{@access_host}#{request_resource}"
        send_request(verb, request_uri)
      end

      def peek(waitseconcds: nil)
        receive(waitseconds: waitseconcds, peekonly: true)
      end

      private

      def to_xml(message_body, delay_seconds, priority)
        xml = Builder::XmlMarkup.new( :indent => 2 )
        xml.instruct! :xml, :encoding => 'UTF-8'
        xml.Message(:xmlns => 'http://mqs.aliyuncs.com/doc/v1/') do |m|
          m.MessageBody message_body
          m.DelaySeconds delay_seconds
          m.Priority priority
        end
      end

    end

  end
end
