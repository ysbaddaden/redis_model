require 'active_model/errors'

module RedisModel
  module Validations
    extend ActiveSupport::Concern

    module ClassMethods
      def human_attribute_name(attr_name, options = {})
        attr_name
      end

      def lookup_ancestors
        [ self ]
      end
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def read_attribute_for_validation(attr_name)
      send(attr_name)
    end

    def valid?
      true
    end
  end
end
