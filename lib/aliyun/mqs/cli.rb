require 'thor'

module Aliyun::Mqs
  class Cli < Thor

    desc "queues", "列出 QueueOwnerId 下的消息队列列表"
    def queues()
      execute("消息队列列表"){ Queue.queues }
    end

    desc "delete [queue]", "删除一个消息队列"
    def delete(name)
      execute("删除消息队列'#{name}'"){ Queue[name].delete }
    end

    desc "create [queue]", "创建一个消息队列"
    def create(name)
      execute("创建消息队列'#{name}'"){ Queue[name].create }
    end

    desc "consume [queue] -wait <wait_seconds>", "从[queue]队列接受消息并删除"
    option :wait
    def consume(name)
      execute("Consume 队列#{name}中的消息") do
        message = Queue[name].receive_message(wait_seconds: options[:wait])
        message.delete
        message
      end
    end

    desc "send [queue] [message]", "往[queue]队列发送[message]消息"
    def send(name, content)
      execute("发送消息到#{name}队列"){ Queue[name].send_message content }
    end

    desc "peek [queue]", "从[queue]队列中peek消息"
    def peek(name)
      execute("Peek 队列#{name}中的消息"){ Queue[name].peek_message }
    end

    private
    def execute info=nil
      begin
        puts info
        result = yield()
        puts result
      rescue RequestException => ex
        puts "#{ex['Code']}: #{ex['Message']}"
      end
      puts "\n"
    end

  end
end
