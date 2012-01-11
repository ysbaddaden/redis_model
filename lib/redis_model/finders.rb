module RedisModel
  module Finders
    def self.included(klass)
      klass.extend(self)
    end

    module ClassMethods
      def self.all
        connection.lrange(key(:all), 0, -1)
      end

      def self.find(id)
        attributes = connection.hgetall(key_from_id(id))
        record = new(attributes)
        record.id = attributes['id']
        record.persisted!
        record
      end
    end
  end
end
