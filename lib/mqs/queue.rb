require 'active_support/core_ext/hash'
require 'base64'
require 'builder'
require 'date'
require 'digest'
require 'net/http'
require 'uri'

module Mqs

  class Queue
    Version     = '2014-07-08'
    ContentType = 'text/xml;utf-8'

    def initialize(name, owner_id: nil)
      @access_key_id     = Mqs.configuration.access_key_id
      @access_key_secret = Mqs.configuration.access_key_secret
      @access_region     = Mqs.configuration.access_region
      @access_owner_id   = owner_id || Mqs.configuration.access_owner_id
      @access_queue = name
      @access_host = "#{@access_owner_id}.mqs-#{@access_region}.aliyuncs.com"
      throw '参数不能为nil' if instance_variables.any? {|x| x == nil}
    end

    def send(message_body, delay_seconds: 0, priority: 8)
      verb = 'POST'
      content_body = to_xml(message_body, delay_seconds, priority)
      content_md5  = Base64::encode64(Digest::MD5.hexdigest(content_body)).chop
      mqs_headers  = {'x-mqs-version' => Version}
      request_resource = "/#{@access_queue}/messages"
      gmt_date = gmt_now
      headers = {'Host' => @access_host,
                 'Date' => gmt_date,
                 'Content-Type' => ContentType,
                 'Content-MD5'  => content_md5
                }
      headers.merge! mqs_headers
      headers['Authorization'] = sign_header(verb, content_md5, ContentType, gmt_date, mqs_headers, request_resource)
      request_uri = "http://#{@access_host}#{request_resource}"
      send_request(request_uri, verb, headers, content_body)
    end

    def receive(waitseconds = nil)
      verb = 'GET'
      content_body = ''
      content_md5 = Base64::encode64(Digest::MD5.hexdigest(content_body)).chop
      gmt_date = gmt_now
      mqs_headers = {'x-mqs-version' => Version}
      request_resource =  "/#{@access_queue}/messages" + (waitseconds ? '?' + {waitseconds: waitseconds}.to_param : '')
      headers = {'Host' => @access_host,
                 'Date' => gmt_date,
                 'Content-Type' => ContentType,
                 'Content-MD5' => content_md5
                }
      headers.merge! mqs_headers
      headers['Authorization'] = sign_header(verb, content_md5, ContentType, gmt_date, mqs_headers, request_resource)
      request_uri = "http://#{@access_host}#{request_resource}"
      send_request(request_uri, verb, headers, content_body)
    end

    def delete message
      verb = 'DELETE'
      content_body = ''
      content_md5 = Base64::encode64(Digest::MD5.hexdigest(content_body)).chop
      gmt_date = gmt_now
      mqs_headers = {'x-mqs-version' => Version}

      if String === message
        receipt_handle = message
      elsif Response === message
        receipt_handle = message.receipt_handle
      end

      request_resource = "/#{@access_queue}/messages?" + {ReceiptHandle: receipt_handle}.to_param
      headers = {'Host' => @access_host,
                 'Date' => gmt_date,
                 'Content-Type' => ContentType,
                 'Content-MD5' => content_md5
                }
      headers.merge! mqs_headers
      headers['Authorization'] = sign_header(verb, content_md5, ContentType, gmt_date, mqs_headers, request_resource)
      request_uri = "http://#{@access_host}#{request_resource}"
      send_request(request_uri, verb, headers, content_body)
    end

    # TODO: implement peek
    def peek

    end

    private

    def gmt_now
      DateTime.now.httpdate
    end

    def sign_header(verb, content_md5, content_type, gmt_date, mqs_headers = {}, resources = '/')
      header = ''
      mqs_headers.sort.each do |k,v|
        header << k.downcase + ':'+  v + "\n"
      end
      sign = sprintf "%s\n%s\n%s\n%s\n%s%s", verb, content_md5, content_type, gmt_date, header, resources
      sign = Base64::encode64(Digest::HMAC.digest(sign, @access_key_secret, Digest::SHA1)).chop
      "MQS #{@access_key_id}:#{sign}"
    end

    def to_xml(message_body, delay_seconds, priority)
      xml = Builder::XmlMarkup.new( :indent => 2 )
      xml.instruct! :xml, :encoding => 'UTF-8'
      xml.Message(:xmlns => 'http://mqs.aliyuncs.com/doc/v1/') do |m|
        m.MessageBody message_body
        m.DelaySeconds delay_seconds
        m.Priority priority
      end
    end

    def send_request(uri, method, headers, body = '')
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      case method.downcase
      when 'get'
        request = Net::HTTP::Get.new(uri.request_uri)
      when 'post'
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = body
      when 'delete'
        request = Net::HTTP::Delete.new(uri.request_uri)
      when 'put'
        request = Net::HTTP::Put.new(uri.request_uri)
        request.body = body
      end
      request.initialize_http_header(headers)
      response = http.request(request)
      Response.new(self, response)
    end

  end

end
