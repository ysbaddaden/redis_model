# IMPROVE: UUID identifiers?
# IMPROVE: counters
module RedisModel
  class RedisModelError < StandardError
  end

  class RecordNotFound < RedisModelError
  end

  class Base
    extend  ActiveModel::Naming
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Conversion
    extend  ActiveModel::Callbacks

    include RedisModel::Connection
    include RedisModel::Attributes
    include RedisModel::Persistance
    include RedisModel::Serializers
    include RedisModel::Finders
    include RedisModel::Validations

    def initialize(attributes = {})
      @attributes = {}
      set_default_attributes
      self.attributes = attributes
    end

    def new_record?
      id.nil?
    end

    def ==(other)
      !new_record? && self.class == other.class && self.id == other.id
    end

    def self.instanciate(attributes)
      record = new(attributes)
      record.id = attributes[:id] || attributes['id']
      record.persisted!
      record.instance_variable_set(:@previously_changed, {})
      record
    end
  end
end
