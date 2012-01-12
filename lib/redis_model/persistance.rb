module RedisModel
  module Persistance
    module ClassMethods
      def key(id = nil)
        key = model_name
        key += ":" + id.to_s unless id.nil?
        key
      end

      def next_id
        connection.incr(key(:id))
      end

      def create(attributes)
        new(attributes).create
      end

      def update(id, attributes)
        record = find(id)
        record.update_attributes(attributes)
        record
      end

      def delete(id)
        connection.del(key(id))
      end

      def destroy(id)
        find(id).destroy
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def key
      self.class.key(id)
    end

    def save
      if new_record?
        create
      else
        update
      end
    end

    def create
      self.id = self.class.next_id
      self.created_at = Time.now   if self.class.attribute_exists?(:created_at)
      self.updated_at = Time.now   if self.class.attribute_exists?(:updated_at)
      self.created_on = Date.today if self.class.attribute_exists?(:created_on)
      self.updated_on = Date.today if self.class.attribute_exists?(:updated_on)
      
      connection.multi do
        connection.hmset(key, @attributes)
        connection.rpush(self.class.key(:all), self.id)
      end
      
      persisted!
    end

    def update
      self.updated_at = Time.now   if self.class.attribute_exists?(:updated_at)
      self.updated_on = Date.today if self.class.attribute_exists?(:updated_on)
      connection.hmset(key, @attributes)
      persisted!
    end

    def update_attributes(attributes)
      self.attributes = attributes
      update
    end

    def delete
      connection.del(key)
    end

    def destroy
      delete
    end

    protected
      def persisted!
        @previously_changed = changes
        @changed_attributes.clear
      end
  end
end
