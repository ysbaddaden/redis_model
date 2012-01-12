require 'active_model/serialization'
require 'active_model/serializers/xml'
require 'active_model/serializers/json'

module RedisModel
  module Serializers
    extend ActiveSupport::Concern

    included do
      self.send :include, ActiveModel::Serialization
      self.send :include, ActiveModel::Serializers::Xml
      self.send :include, ActiveModel::Serializers::JSON
      self.include_root_in_json = false
    end

#    def to_hash
#      Hash[*self.class.attribute_names.collect { |key| [ key, send(key) ] }.flatten]
#    end
  end
end
