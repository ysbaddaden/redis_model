# IMPROVE: UUID identifiers?
# IMPROVE: counters
module RedisModel
  class RecordNotFound < StandardError
  end

  class Base
    extend  ActiveModel::Naming
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Conversion

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

    def persisted?
      !new_record?
    end
  end
end
