module Aliyun::Mqs
  class Queue
    attr_reader :name

    delegate :to_s, to: :name

    class << self
      def [] name
        Queue.new(name)
      end

      def queues opts={}
        mqs_options = {query: "x-mqs-prefix", offset: "x-mqs-marker", size: "x-mqs-ret-number"}
        mqs_headers = opts.slice(*mqs_options.keys).reduce({}){|mqs_headers, item| k, v = *item; mqs_headers.merge!(mqs_options[k]=>v)}
        response = Request.get("/", mqs_headers: mqs_headers)
        Hash.xml_array(response, "Queues", "Queue").collect{|item| Queue.new(URI(item["QueueURL"]).path.sub!(/^\//, ""))}
      end
    end

    def initialize name
      @name = name
    end

    def create opts={}
      response = Request.put(queue_path) do |request|
        msg_options = {
          :VisibilityTimeout => 30,
          :DelaySeconds => 0,
          :MaximumMessageSize => 65536,
          :MessageRetentionPeriod => 345600,
          :PollingWaitSeconds => 0}.merge(opts)
        request.content :Queue, msg_options
      end
    end

    def delete
      Request.delete(queue_path)
    end

    def send_message message, opts={}
      Request.post(messages_path) do |request|
        msg_options = {:DelaySeconds => 0, :Priority => 10}.merge(opts)
        request.content :Message, msg_options.merge(:MessageBody => message.to_s)
      end
    end

    def receive_message wait_seconds: nil
      request_opts = {}
      request_opts.merge!(params:{waitseconds: wait_seconds}) if wait_seconds
      result = Request.get(messages_path, request_opts)
      Message.new(self, result)
    end

    def peek_message
      result = Request.get(messages_path, params: {peekonly: true})
      Message.new(self, result)
    end

    def queue_path
      "/#{name}"
    end

    def messages_path
      "/#{name}/messages"
    end

  end
end
