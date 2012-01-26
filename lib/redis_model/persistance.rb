module RedisModel
  module Persistance
    extend ActiveSupport::Concern

    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(attr_name, options = {})
        indices[attr_name.to_sym] = options
      end

      def index_key(attr_name, value = nil)
        k = key("idx:#{attr_name}")
        k += ":" + value.to_s unless value.nil?
        k
      end

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
          connection.lrem(index_key(:id), 0, id)
        end
      end

      def destroy(id)
        record = find(id)
        record.destroy
        record
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
      self.id ||= self.class.next_id
      
      self.created_at = Time.now   if self.class.attribute_exists?(:created_at)
      self.updated_at = Time.now   if self.class.attribute_exists?(:updated_at)
      self.created_on = Date.today if self.class.attribute_exists?(:created_on)
      self.updated_on = Date.today if self.class.attribute_exists?(:updated_on)
      
      connection.multi do
        connection.hmset(key, *attributes.flatten)
        
        self.class.indices.each do |attr_name, options|
          if options[:unique]
            connection.hsetnx(self.class.index_key(attr_name), id)
          elsif options[:serial]
            connection.rpush(self.class.index_key(attr_name), id)
          else
            connection.rpush(self.class.index_key(attr_name, send(attr_name)), id)
          end
        end
      end
      
      persisted!
    end

    def update
      self.updated_at = Time.now   if self.class.attribute_exists?(:updated_at)
      self.updated_on = Date.today if self.class.attribute_exists?(:updated_on)
      connection.hmset(key, *attributes.flatten)
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
      destroyed!
    end

    def destroy
      delete
      self
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def destroyed?
      @destroyed == true
    end

    def persisted! # :nodoc:
      @previously_changed = changes
      @changed_attributes.clear
    end

    def destroyed! # :nodoc:
      @destroyed = true
    end
  end
end
