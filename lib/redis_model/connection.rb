gem 'redis'
require 'redis'

module RedisModel
  module Connection
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def connection
        @connection || @@connection ||= ::Redis.new
      end

      def connection=(redis)
        @connection = redis
      end
    end

    def connection
      @connection || self.class.connection
    end

    def connection=(redis)
      @connection = redis
    end
  end
end
