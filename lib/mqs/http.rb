require 'base64'
require 'date'
require 'digest'
require 'net/http'
require 'uri'

module Mqs
  module Http
    Version     = '2014-07-08'
    ContentType = 'text/xml;utf-8'

    def send_request(verb, request_uri, body = '')
      uri = URI.parse(request_uri)
      content_md5 = Base64::encode64(Digest::MD5.hexdigest body).chop
      gmt_date = DateTime.now.httpdate
      mqs_headers = {'x-mqs-version' => Version}
      headers = {'Host' => uri.host,
                 'Date' => gmt_date,
                 'Content-Type' => ContentType,
                 'Content-MD5' => content_md5
                }
      headers.merge! mqs_headers
      resource = uri.path + (uri.query != nil ? '?' + uri.query : '')
      headers['Authorization'] = sign_header(verb, content_md5, gmt_date, mqs_headers, resource)

      http = Net::HTTP.new(uri.host, uri.port)

      case verb.downcase
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

    def sign_header(verb, content_md5, gmt_date, mqs_headers = {}, resources = '/')
      header = ''
      mqs_headers.sort.each do |k,v|
        header << k.downcase + ':'+  v + "\n"
      end
      sign = sprintf "%s\n%s\n%s\n%s\n%s%s", verb, content_md5, ContentType, gmt_date, header, resources
      sign = Base64::encode64(Digest::HMAC.digest(sign, Mqs.configuration.access_key_secret, Digest::SHA1)).chop
      "MQS #{Mqs.configuration.access_key_id}:#{sign}"
    end

  end
end
