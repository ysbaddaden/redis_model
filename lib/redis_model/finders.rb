module RedisModel
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def count
        connection.llen(key(:all))
      end

      def hkey(attr_name)
        key("*->#{attr_name}")
      end

      def all
        _find_all(key(:all))
      end

      def find(id)
        attributes = connection.hgetall(key(id))
        raise RedisModel::RecordNotFound.new("No such #{model_name} with id: #{id}") if attributes.empty?
        instanciate(attributes)
      end

      def exists?(id)
        connection.exists(key(id))
      end

      def first
        ids = connection.lrange(key(:all), 0, 0)
        instanciate(connection.hgetall(key(ids.first))) if ids.any?
      end

      def last
        ids = connection.lrange(key(:all), -1, -1)
        instanciate(connection.hgetall(key(ids.first))) if ids.any?
      end

      protected
        def instanciate(attributes)
          record = new(attributes)
          record.id = attributes[:id] || attributes['id']
          record.persisted!
          record
        end

        def _find_all(key)
          collection = []
          keys = attribute_names.sort
          results = connection.sort(key, :by => :nosort, :get => keys.collect { |k| hkey(k) })
          results.each_slice(keys.size) do |values|
            collection << instanciate(Hash[ *keys.zip(values).flatten ])
          end
          collection
        end
    end

    def reload
      attributes = connection.hgetall(key)
      @attributes = {}
      self.attributes = attributes
      persisted!
      self
    end
  end
end
