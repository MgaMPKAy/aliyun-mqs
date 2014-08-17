# aliyun-mqs

Talk to the mighty Aliyun MQS with charming ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aliyun-mqs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aliyun-mqs

## Usage

### Require

```ruby
require 'mqs'
```

Yes, require `mqs` instead of `aliyun-mqs`. It's kind of wired and unconsistent.

### Configure

```ruby
Mqs.configure do |config|
  config.access_key_id     = '0123456789ABCDEF'
  config.access_key_secret = '*********************'
  config.access_region     = 'cn-hangzhou'
  config.access_owner_id   = 'cirno'
end
```

### Response

Every leaf element in the XML response becames an attribute in the `Response` object, eg:


```xml
<?xml version="1.0"?>
<Message xmlns="http://mqs.aliyuncs.com/doc/v1">
  <MessageBodyMD5>65A8E27D8879283831B664BD8B7F0AD4</MessageBodyMD5>
  <MessageId>6001A74BEB1D5460-1-147DF4497D4-200000024</MessageId>
</Message>
```

becames:

```ruby
resp.message_body_md5
resp.message_id
```

To determine wheater a request call is succeed, use `Response::success?`

### Get an existing queue

```ruby
queue = Mqs::Queue.get 'queue-name'
queue = Mqs::Queue.get 'queue-name', :access_owner_id: 'your_id'
```

### Delete a queue

```ruby
queue.destroy
```

### Send messages

```ruby
resp = queue.send "Hello, World!"
resp = queue.send "Hello, Cirno!", delay_seconds: 9, priority: 9
```

### Recveive messages

```ruby
message = queue.receive
message = queue.receive waitseconds: 10, peekonly: true
message = queue.peek
```

### Delete messages

```ruby
message.delete
queue.delete message
queue.delete "#{you_message_recipet_handlerer}"
```

## Contributing

1. Fork it ( https://github.com/mgampkay/aliyun-mqs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## References

+ xiaohuilam's [aliyun-mqs-php-library](https://github.com/xiaohuilam/aliyun-mqs-php-library)
