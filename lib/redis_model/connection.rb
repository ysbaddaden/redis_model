module RedisModel
  def self.connection
    @@connection ||= Redis.new
  end

  def self.connection=(redis)
    @@connection = redis
  end

  module Connection
    extend ActiveSupport::Concern

    module ClassMethods
      def connection
        @connection || RedisModel.connection
      end

      def connection=(redis)
        @connection = redis
      end
    end

    def connection
      self.class.connection
    end
  end
end
