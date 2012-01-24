module RedisModel
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def count
        connection.llen(index_key(:id))
      end

      def hkey(attr_name)
        key("*->#{attr_name}")
      end

      def all
        _find_all(:id)
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
        ids = connection.lrange(index_key(:id), 0, 0)
        instanciate(connection.hgetall(key(ids.first))) if ids.any?
      end

      def last
        ids = connection.lrange(index_key(:id), -1, -1)
        instanciate(connection.hgetall(key(ids.first))) if ids.any?
      end

      def method_missing(method_name, *args)
        if method_name.to_s =~ /^find_(all_by|by)_(.*)$/
          case $1
          when 'all_by'
            _find_all($2, args.first)
          when 'by'
            super
          end
        else
          super
        end
      end

      protected
        def instanciate(attributes)
          record = new(attributes)
          record.id = attributes[:id] || attributes['id']
          record.persisted!
          record
        end

        def _find_all(attr_name, value = nil)
          keys = attribute_names.sort
          results = connection.sort(
            index_key(attr_name, value),
            :by  => :nosort,
            :get => keys.collect { |k| hkey(k) }
          )
          collection = []
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
