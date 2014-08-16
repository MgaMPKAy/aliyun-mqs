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

~~~
require 'mqs'
~~

Why `mqs` instead of `aliyun-mqs`? This might be changed later.

### Configure

~~~
Mqs.configure do |config|
  config.access_key_id     = '0123456789ABCDEF'
  config.access_key_secret = '*********************'
  config.access_region     = 'cn-hangzhou'
  config.access_owner_id   = 'cirno'
end
~~~

### Get an existing queue

~~~
queue = Mqs::Queue.new 'queue-name'
queue = Mqs::Queue.new 'queue-name', :owner_id: 'your_id' # overwrite configurations
~~~

### Send messages

~~~
resp = queue.send "Hello, World!"
resp = queue.send "Hello, Cirno!", delay_seconds: 9, priority: 9
~~~

### Recveive messages

~~~
message = queue.receive
message = queue.receive waitseconds: 10, peekonly: true
message = queue.peek
~~~

### Delete messages
~~~
message.delete

queue.delete message

queue.delete "#{you_message_recipet_handlerer}"
~~~

## Contributing

1. Fork it ( https://github.com/mgampkay/aliyun-mqs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## References

+ xiaohuilam's [aliyun-mqs-php-library](https://github.com/xiaohuilam/aliyun-mqs-php-library)
