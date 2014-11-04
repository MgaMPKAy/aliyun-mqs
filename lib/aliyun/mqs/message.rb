module Aliyun::Mqs
  class Message

    attr_reader :queue, :id, :body_md5, :body, :receipt_handle, :enqueue_at, :first_enqueue_at, :next_visible_at, :dequeue_count, :priority

    def initialize queue, content
      h = Hash.xml_object(content, "Message")
      @queue = queue
      @id = h["MessageId"]
      @body_md5 = h["MessageBodyMD5"]
      @body = h["MessageBody"]
      @enqueue_at = Time.at(h["EnqueueTime"].to_i/1000.0)
      @first_enqueue_at = Time.at(h["FirstDequeueTime"].to_i/1000.0)
      @next_visible_at = Time.at(h["NextVisibleTime"].to_i/1000.0) if h["NextVisibleTime"]
      @dequeue_count = h["DequeueCount"].to_i
      @priority = h["Priority"].to_i
      @receipt_handle = h["ReceiptHandle"]
    end

    def delete
      check_receipt_handle
      Aliyun::Mqs::Request.delete(queue.messages_path, params:{:ReceiptHandle => receipt_handle})
    end

    def change_visibility seconds
      check_receipt_handle
      Aliyun::Mqs::Request.put(queue.messages_path, params:{:ReceiptHandle => receipt_handle, :VisibilityTimeout=>seconds})
    end

    def to_s
      s = {
        "队列"=> queue.name, 
        "ID"=>id, 
        "MD5"=>body_md5, 
        "Receipt handle"=>receipt_handle, 
        "Enqueue at"=>enqueue_at,
        "First enqueue at"=>first_enqueue_at,
        "Next visible at"=>next_visible_at,
        "Dequeue count" => dequeue_count,
        "Priority"=>priority
      }.collect{|k,v| "#{k}: #{v}"}

      sep = "============================================="
      s.unshift sep
      s << sep
      s << body
      s.join("\n")
    end

    private 
    def check_receipt_handle
      raise "No receipt handle for this operation" unless receipt_handle
    end

  end
end