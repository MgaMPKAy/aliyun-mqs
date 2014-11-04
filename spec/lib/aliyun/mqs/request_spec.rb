require 'spec_helper'

describe Aliyun::Mqs::Request do
  
  describe "Reqest methods" do
    specify "get" do
      expect(RestClient).to receive(:get) do |*args|
        path, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/path")
        expect(headers).to be_a(Hash)
      end

      Aliyun::Mqs::Request.get("/path")
    end

    specify "get with params" do
      expect(RestClient).to receive(:get) do |*args|
        path, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/path?a=1")
        expect(headers).to be_a(Hash)
      end
      
      Aliyun::Mqs::Request.get("/path", params:{a:1})
    end

    specify "get with mqs_headers" do
      expect(RestClient).to receive(:get) do |*args|
        path, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/path")
        expect(headers.slice("x-mqs-1")).to eq("x-mqs-1"=>"1")
      end
      
      Aliyun::Mqs::Request.get("/path", mqs_headers:{"x-mqs-1"=>"1"})
    end
   
    specify "delete" do
      expect(RestClient).to receive(:delete) do |*args|
        path, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/path")
        expect(headers).to be_a(Hash)
      end

      Aliyun::Mqs::Request.delete("/path")
    end

    specify "post with content" do
      expect(RestClient).to receive(:post) do |*args|
        path, body, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/path")
        expect(body).not_to be_empty
        expect(headers).to be_a(Hash)
      end

      Aliyun::Mqs::Request.post("/path"){|request| request.content "content"}
    end

    specify "put with content" do
      expect(RestClient).to receive(:put) do |*args|
        path, body, headers = *args
        expect(path).to eq("http://owner-id.mqs-region.aliyuncs.com/path")
        expect(body).not_to be_empty
        expect(headers).to be_a(Hash)
      end
      
      Aliyun::Mqs::Request.put("/path"){|request| request.content "content"}
    end
  end

  specify "has default x-mqs-version header" do
    expect(subject.mqs_headers).to eq("x-mqs-version" => "2014-07-08")
  end

  specify "has default content namespace when content is set" do
    subject.content("content", attr1: 1, attr2: 2)
    xml = Hash.from_xml(subject.body)

    expect(subject.content_type).to eq("text/xml;charset=utf-8")
    expect(xml["content"]["xmlns"]).to eq("http://mqs.aliyuncs.com/doc/v1/")
    expect(subject.content_length).not_to be_nil
    expect(subject.content_md5).not_to be_nil
  end

end
