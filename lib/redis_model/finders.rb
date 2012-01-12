module RedisModel
  module Finders
    def self.included(klass)
      klass.extend(self)
    end

    module ClassMethods
      def self.all
        connection.lrange(key(:all), 0, -1).collect do |attributes|
          instanciate(attributes)
        end
      end

      def self.find(id)
        record = new
        record.id = id
        record.reload
      end

      def self.first
        ary = connection.lrange(key(:all), -1, -1)
        instanciate(ary.first) if ary.any?
      end

      def self.last
        ary = connection.lrange(key(:all), 0, 0)
        instanciate(ary.first) if ary.any?
      end

      protected
        def instanciate(attributes)
          record = new(attributes)
          record.id = attributes['id']
          record.persisted!
          record
        end
    end

    def reload
      @attributes = {}
      attributes = connection.hgetall(key)
      persisted!
      self
    end
  end
end
