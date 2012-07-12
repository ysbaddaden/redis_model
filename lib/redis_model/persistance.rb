module RedisModel
  module Persistance
    extend ActiveSupport::Concern

    included do |klass|
      define_model_callbacks :save, :create, :update, :destroy
    end

    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(attr_name, options = {})
        indices[attr_name.to_sym] = options
      end

      def index_key(attr_name, value = nil)
        k = "#{model_name}_idx:#{attr_name}"
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
        find(id).delete
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
      if new_record? then create else update end
    end

    def create
      self.id = self.class.next_id
      
      run_callbacks :save do
        run_callbacks :create do
          self.created_at = Time.now   if self.class.attribute_exists?(:created_at)
          self.updated_at = Time.now   if self.class.attribute_exists?(:updated_at)
          self.created_on = Date.today if self.class.attribute_exists?(:created_on)
          self.updated_on = Date.today if self.class.attribute_exists?(:updated_on)
          
          connection.multi do
            connection.hmset(key, *attributes.flatten)
            update_indices
          end
          
          persisted!
        end
      end
    end

    def update
      run_callbacks :save do
        run_callbacks :update do
          self.updated_at = Time.now   if self.class.attribute_exists?(:updated_at)
          self.updated_on = Date.today if self.class.attribute_exists?(:updated_on)

          connection.multi do
            connection.hmset(key, *attributes.flatten)
            update_indices
          end

          persisted!
        end
      end
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
      connection.del(key)
      delete_indices
      destroyed!
    end

    def destroy
      run_callbacks(:destroy) { delete }
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

    private
      def update_indices
        self.class.indices.each do |attr_name, options|
          if send("#{attr_name}_changed?")
            was = send("#{attr_name}_was")
            now = send(attr_name)
            
            if options[:serial]
              connection.srem(self.class.index_key(attr_name), id) unless was.nil?
              connection.sadd(self.class.index_key(attr_name), id) unless now.nil?
            else
              if options[:unique]
                connection.hdel(self.class.index_key(attr_name), was) unless was.nil?
                connection.hsetnx(self.class.index_key(attr_name), value, id) unless now.nil?
              end
              connection.srem(self.class.index_key(attr_name, was), id) unless was.nil?
              connection.sadd(self.class.index_key(attr_name, send(attr_name)), id) unless now.nil?
            end
          end
        end
      end

      def delete_indices
        self.class.indices.each do |attr_name, options|
          if options[:serial]
            connection.srem(self.class.index_key(attr_name), id)
          else
            value = send(attr_name)
            unless value.nil?
              connection.hdel(self.class.index_key(attr_name), value) if options[:unique]
              connection.srem(self.class.index_key(attr_name, value), id)
            end
          end
        end
      end
  end
end
