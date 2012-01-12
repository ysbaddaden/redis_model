module RedisModel
  module Finders
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def count
        connection.llen(key(:all))
      end

      def all
        connection.lrange(key(:all), 0, -1).collect do |id|
          instanciate(connection.hgetall(key(id)))
        end
      end

      def find(id)
        attributes = connection.hgetall(key(id))
        if attributes.empty?
          raise RedisModel::RecordNotFound.new("No such #{model_name} with id: #{id}")
        else
          record = new(attributes)
          record.id = id
          record.persisted!
          record
        end
      end

      def exists?(id)
        connection.exists(key(id))
      end

      def first
        ary = connection.lrange(key(:all), -1, -1)
        instanciate(ary.first) if ary.any?
      end

      def last
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
