require 'spec_helper'

describe Aliyun::Mqs::Queue do

  let(:xml_message){
    Aliyun::Mqs::Message.new(Aliyun::Mqs::Queue["aQueue"], <<-XML)
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

  let(:peek_xml_message){
    Aliyun::Mqs::Message.new(Aliyun::Mqs::Queue["aQueue"], <<-XML)
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

  describe "#delete" do
    specify "will delete the message from queue" do
      expect(Aliyun::Mqs::Request).to receive(:delete).with("/aQueue/messages", params:{:ReceiptHandle=>"MbZj6wDWli+QEauMZc8ZRv37sIW2iJKq3M9Mx/KSbkJ0"})
      xml_message.delete
    end

    specify "won't delete message without receipt_handle" do
      expect{peek_xml_message.delete}.to raise_exception
    end
  end

  describe "#change_visibility" do
    specify "will change message's visibility timeout" do
      expect(Aliyun::Mqs::Request).to receive(:put).with("/aQueue/messages", params:{
        :ReceiptHandle=>"MbZj6wDWli+QEauMZc8ZRv37sIW2iJKq3M9Mx/KSbkJ0",
        :VisibilityTimeout => 10
      })

      xml_message.change_visibility 10
    end

    specify "won't change message's visibility timeout given message has no receipt_handle" do
      expect{peek_xml_message.change_visibility 10}.to raise_exception
    end
  end

end