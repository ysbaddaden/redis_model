# FIXME: should pushing an unpersisted child actually save the child before proceeding?
module RedisModel
  class Relation
    attr_reader :name, :klass, :parent, :foreign_key
    delegate :collect, :each, :each_index, :each_with_index, :as_json, :to_json, :to => :to_a

    def initialize(name, klass, parent, foreign_key)
      @name = name.to_sym
      @parent = parent
      @klass = klass
      @foreign_key = foreign_key
      @loaded = false
    end

    def size
      connection.zcard(key).to_i
    end

    def empty?
      size == 0
    end

    def any?
      size > 1
    end

    def index(record)
      zrank(key, record.id)
    end

    def include?(record)
      !index(record).nil?
    end

    def key
      parent.key + ":" + name.to_s
    end

    def to_a
      if @collection.nil?
        @collection = []
        connection.zrank(key, 0, -1).each do |id|
          @collection << instanciate(connection.hgetall(klass.key(id)))
        end
        @loaded = true
      end
      @collection
    end

    def push(record)
      raise AssociationTypeMismatch.new("#{klass.name} expected, got #{record.class.name}") if record.class != klass
      record.send("#{foreign_key}=", parent.id)
      record.save
      to_a.push(record) if loaded?
      _push(record.id)
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
        !!connection.sismember(key, id)
      end
    end

    def find(id)
      record = _find(id)
      raise RecordNotFound.new("Couldn't find child #{klass.name} with ID #{id} for parent #{parent.class.name} with ID #{parent.id}") if record.nil?
      record
    end

    def first
      if loaded?
        to_a.first
      else
        id = connection.zrange(key, 0, 0).first
        
        p id
        p connection.hgetall(klass.key(id))
        
        klass.send :instanciate, connection.hgetall(klass.key(id))
      end
    end

    def last
      if loaded?
        to_a.last
      else
        id = connection.zrange(key, -1, -1).first
        klass.send :instanciate, connection.hgetall(klass.key(id))
      end
    end

    def connection
      RedisModel.connection
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

      # ensures that no record can share the same index (since sorted sets rely on a score)
      def _push(id)
        rs = nil
        while rs.nil?
          connection.watch(key)
          index = connection.zcard(key)
          rs = connection.multi { connection.zadd(key, index, id) }
        end
      ensure
        connection.unwatch
      end

      def _remove(id, record = nil)
        to_a.delete(record || _find(id)) if loaded?
        connection.zrem(key, id)
      end
  end
end
