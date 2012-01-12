module RedisModel
  module Persistance
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def key(id = nil)
        key = model_name
        key += ":" + id.to_s unless id.nil?
        key
      end

      def next_id
        connection.incr(key(:id))
      end

      def create(attributes = {})
        record = new(attributes)
        record.create
        record
      end

      def update(id, attributes = {})
        record = find(id)
        record.update_attributes(attributes)
        record
      end

      def delete(id)
        connection.multi do
          connection.del(key(id))
          connection.lrem(id)
        end
      end

      def destroy(id)
        find(id).destroy
      end
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
#        connection.hmset(key, attributes.flatten)
        attributes.each do |attr_name, value|
          connection.hset(key, attr_name, value.to_s)
        end
        connection.rpush(self.class.key(:all), self.id)
      end
      
      persisted!
    end

    def update
      self.updated_at = Time.now   if self.class.attribute_exists?(:updated_at)
      self.updated_on = Date.today if self.class.attribute_exists?(:updated_on)
      
#      connection.hmset(key, attributes.flatten)
      connection.multi do
        attributes.each do |attr_name, value|
          connection.hset(key, attr_name, value.to_s)
        end
      end
      
      persisted!
    end

    def update_attribute(attr_name, value)
      send("#{attr_name}=", value)
      save
    end

    def update_attributes(attributes)
      self.attributes = attributes
      save
    end

    def delete
      self.class.delete(id)
    end

    def destroy
      delete
    end

    def persisted! # :nodoc:
      @previously_changed = changes
      @changed_attributes.clear
    end
  end
end
