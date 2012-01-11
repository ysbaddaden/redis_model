module RedisModel
  class Base
    extend  ActiveModel::Naming
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty
    include ActiveModel::MassAssignmentSecurity

    include RedisModel::Connection
    include RedisModel::Attributes
    include RedisModel::Serializers
    include RedisModel::Finders

    def self.key(id = nil)
      key = model_name
      key += ":" + id.to_s unless id.nil?
      key
    end

    def self.next_id
      connection.incrby(key(:id), 1)
    end

    attr_writer    :id
    attr_protected :id

    def initialize(attributes = {})
      @attributes = {}
      sanitize_for_mass_assignment(attributes).each do |key, value|
        self.send("#{key}=".to_sym, value)
      end
    end

    def id
      read_attribute(:id)
    end

    def key
      self.class.key(id)
    end

    def new_record?
      id.nil?
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
      self.created_on = Date.today if self.class.attribute_exists?(:created_on)
      self.created_at = Time.now   if self.class.attribute_exists?(:created_at)
      
      connection.multi do
        connection.hmset(key, @attributes)
        connection.rpush(self.class.key(:all), self.id)
      end
      
      persisted!
    end

    def update
      self.created_on = Date.today if self.class.attribute_exists?(:created_on)
      self.created_at = Time.now   if self.class.attribute_exists?(:created_at)
      connection.hmset(key, @attributes)
      persisted!
    end

    def destroy
      connection.del(key)
    end

    def reload
      @attributes = connection.hgetall(key)
      persisted!
    end
    
    protected
      def persisted!
        @previously_changed = changes
        @changed_attributes.clear
      end
  end
end
