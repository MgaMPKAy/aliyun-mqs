require 'spec_helper'

describe Aliyun::Mqs::Queue do
  
  specify ".[] will create new queue instance" do
    queue = Aliyun::Mqs::Queue["aQueue"]
    expect(queue).not_to be_nil
    expect(queue.name).to eq("aQueue")
  end

  describe ".queues" do
    let(:xml_response){
       <<-XML
        <?xml version="1.0"?>
        <Queues xmlns="http://mqs.aliyuncs.com/doc/v1">
          <Queue>
            <QueueURL>http://xxxxx.mqs-cn-hangzhou.aliyuncs.com/test</QueueURL>
          </Queue>
        </Queues>
      XML
    }

    specify "find all queues" do
      expect(Aliyun::Mqs::Request).to receive(:get).with("/", mqs_headers:{}).and_return xml_response
      queues = Aliyun::Mqs::Queue.queues
      expect(queues.size).to eq(1)
      expect(queues[0].name).to eq("test")
    end

    specify "query queues" do
      expect(Aliyun::Mqs::Request).to receive(:get).with("/", mqs_headers:{"x-mqs-prefix"=>"query"}).and_return xml_response
      queues = Aliyun::Mqs::Queue.queues(query: "query")
    end

    specify "find number of queues" do
      expect(Aliyun::Mqs::Request).to receive(:get).with("/", mqs_headers:{"x-mqs-ret-number"=>5}).and_return xml_response
      queues = Aliyun::Mqs::Queue.queues(size: 5)
    end

    specify "find of queues start at given position" do
      expect(Aliyun::Mqs::Request).to receive(:get).with("/", mqs_headers:{"x-mqs-marker"=>2}).and_return xml_response
      queues = Aliyun::Mqs::Queue.queues(offset: 2)
    end
  end


  describe "#create" do
    specify "will create a new queue with default options" do
      expect(RestClient).to receive(:put) do |*args|
        path, body, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/aQueue")
        xml = Hash.from_xml(body)
        expect(xml["Queue"]["VisibilityTimeout"]).to eq("30")
        expect(xml["Queue"]["DelaySeconds"]).to eq("0")
        expect(xml["Queue"]["MaximumMessageSize"]).to eq("65536")
        expect(xml["Queue"]["MessageRetentionPeriod"]).to eq("345600")
        expect(xml["Queue"]["PollingWaitSeconds"]).to eq("0")
        expect(headers).not_to be_nil
      end
      Aliyun::Mqs::Queue["aQueue"].create
    end

    specify "will create a new queue with customized options" do
      expect(RestClient).to receive(:put) do |*args|
        path, body, headers = *args
        expect(Hash.from_xml(body)["Queue"]["PollingWaitSeconds"]).to eq("30")
      end
      Aliyun::Mqs::Queue["aQueue"].create(:PollingWaitSeconds => 30)
    end
  end

  describe "#delete" do
    specify "will delete existing queue" do
      expect(Aliyun::Mqs::Request).to receive(:delete).with("/aQueue")
      Aliyun::Mqs::Queue["aQueue"].delete
    end
  end

  describe "#send_message" do
    specify "will send a message to a queue with default options" do
      expect(RestClient).to receive(:post) do |*args|
        path, body, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/aQueue/messages")
        xml = Hash.from_xml(body)
        expect(xml["Message"]["MessageBody"]).to eq("text message")
        expect(xml["Message"]["DelaySeconds"]).to eq("0")
        expect(xml["Message"]["Priority"]).to eq("10")
        expect(headers).not_to be_nil
      end

      Aliyun::Mqs::Queue["aQueue"].send_message "text message"
    end


    specify "will send a message to a queue with customized options" do
      expect(RestClient).to receive(:post) do |*args|
        path, body, headers = *args
        expect(Hash.from_xml(body)["Message"]["Priority"]).to eq("1")
      end

      Aliyun::Mqs::Queue["aQueue"].send_message "text message", :Priority=>1
    end
  end
  

  describe "#receive_message" do
    let(:xml_response){
      <<-XML
      <?xml version="1.0" encoding="UTF-8" ?> 
      <Message xmlns="http://mqs.aliyuncs.com/doc/v1/">
        <MessageId>5fea7756-0ea4-451a-a703-a558b933e274</MessageId> 
        <ReceiptHandle>MbZj6wDWli+QEauMZc8ZRv37sIW2iJKq3M9Mx/KSbkJ0</ReceiptHandle>
        <MessageBodyMD5>fafb00f5732ab283681e124bf8747ed1</MessageBodyMD5> 
        <MessageBody>This is a test message</MessageBody>
        <EnqueueTime>1250700979248000</EnqueueTime> 
        <NextVisibleTime>1250700799348000</NextVisibleTime>
        <FirstDequeueTime>1250700779318000</FirstDequeueTime > 
        <DequeueCount>1</DequeueCount >
        <Priority>8</Priority>
      </Message>
      XML
    }

    specify "will receive message from a queue" do
      expect(Aliyun::Mqs::Request).to receive(:get).with("/aQueue/messages",{}).and_return xml_response

      message = Aliyun::Mqs::Queue["aQueue"].receive_message
      expect(message).not_to be_nil
      expect(message.id).to eq("5fea7756-0ea4-451a-a703-a558b933e274")
      expect(message.body).to eq("This is a test message")
      expect(message.body_md5).to eq("fafb00f5732ab283681e124bf8747ed1")
      expect(message.receipt_handle).to eq("MbZj6wDWli+QEauMZc8ZRv37sIW2iJKq3M9Mx/KSbkJ0")
      expect(message.enqueue_at).to eq(Time.at(1250700979248000/1000.0))
      expect(message.first_enqueue_at).to eq(Time.at(1250700779318000/1000.0))
      expect(message.next_visible_at).to eq(Time.at(1250700799348000/1000.0))
      expect(message.dequeue_count).to eq(1)
      expect(message.priority).to eq(8)
    end

    specify "will receive message from a queue with poll wait" do
      expect(Aliyun::Mqs::Request).to receive(:get).with("/aQueue/messages",params:{waitseconds: 60}).and_return xml_response
      message = Aliyun::Mqs::Queue["aQueue"].receive_message wait_seconds: 60
    end
  end

  describe "#peek" do
    let(:xml_response){
      <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
      <Message xmlns="http://mqs.aliyuncs.com/doc/v1/">
        <MessageId>5fea7756-0ea4-451a-a703-a558b933e274</MessageId>
        <MessageBodyMD5>fafb00f5732ab283681e124bf8747ed1</MessageBodyMD5>
        <MessageBody>This is a test message</MessageBody>
        <EnqueueTime>1250700979248000</EnqueueTime>
        <FirstDequeueTime>1250700979348000</FirstDequeueTime>
        <DequeueCount>5</DequeueCount>
        <Priority>8</Priority>
      </Message>
      XML
    }

    specify "will peek message of a queue" do
      expect(Aliyun::Mqs::Request).to receive(:get).with("/aQueue/messages",params:{peekonly: true}).and_return xml_response
      message = Aliyun::Mqs::Queue["aQueue"].peek_message

      expect(message).not_to be_nil
      expect(message.id).to eq("5fea7756-0ea4-451a-a703-a558b933e274")
      expect(message.body).to eq("This is a test message")
      expect(message.body_md5).to eq("fafb00f5732ab283681e124bf8747ed1")
      expect(message.receipt_handle).to be_nil
      expect(message.enqueue_at).to eq(Time.at(1250700979248000/1000.0))
      expect(message.first_enqueue_at).to eq(Time.at(1250700979348000/1000.0))
      expect(message.next_visible_at).to be_nil
      expect(message.dequeue_count).to eq(5)
      expect(message.priority).to eq(8)
    end
  end

end