module RedisModel
  class Relation
    attr_reader :name, :klass, :parent

    delegate :collect, :each, :each_index, :each_with_index,
      :index, :include?, :as_json, :to_json, :to => :to_a

    def initialize(name, klass, parent)
      @name   = name
      @parent = parent
      @klass  = klass
      @loaded = false
    end

    def size
      if loaded?
        to_a.size
      else
        RedisModel.connection.zcard(key).to_i
      end
    end

    def empty?
      size == 0
    end

    def any?
      size > 1
    end

    def key
      klass.key + ":" + name
    end

    def to_a
      if @collection.nil?
        @collection = klass.send(:_find_all, key)
        @loaded = true
      end
      @collection
    end

    def push(record)
      to_a.push(record) if loaded?
      RedisModel.connection.zadd(key, size, record)
    end
    alias :<< :push

    def remove(record)
      _remove(record.id, record)
    end

    def save
      to_a.each { |record| record.save }
    end

    def create(attributes = {})
      record = klass.new(attributes.merge(name => parent))
      record.id = klass.next_id
      redis.multi do
        record = klass.save
        push(record)
      end
      record
    end

    def delete(id)
      redis.multi do
        record = remove_by_id(id)
        klass.delete(id)
      end
    end

    def destroy(id)
      record = klass.find(id)
      redis.multi do
        record.destroy
        remove(record)
      end
    end

    def exists?(id)
      if loaded?
        to_a.each { |record| return true if record.id.to_s == id.to_s }
        return false
      else
        !!RedisModel.connection.sismember(key, id)
      end
    end

    def find(id)
      record = _find(id)
      raise RecordNotFound.new("Couldn't find child #{klass.name} with ID #{id} for parent #{parent.class.name} with ID #{parent.id}") if record.nil?
      record
    end

    private
      def loaded?
        !!@loaded
      end

      def _find(id)
        if loaded?
          to_a.each { |record| return record if record.id.to_s == id.to_s }
        elsif exists?(id)
          klass.find(id)
        end
      end

      def _remove(id, record = nil)
        to_a.delete(record || _find(id)) if loaded?
        RedisModel.connection.zrem(key, id)
      end
  end
end
