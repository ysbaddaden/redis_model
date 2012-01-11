require 'time'

module RedisModel
  module Types # :nodoc: all
    def self.parse_string(value)
      String(value)
    end

    def self.parse_integer(value)
      Integer(value)
    end

    def self.parse_float(value)
      Float(value)
    end

    def self.parse_date(value)
      Date.parse(value)
    end

    def self.parse_time(value)
      Time.parse(value)
    end
  end

  module Attributes
    def self.included(klass) # :nodoc:
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def attribute(attr_name, type = :string, options = {})
        self.schema ||= {}
        
        attr_name = attr_name.to_sym
        schema[attr_name] = options.merge(:type => type)

        define_attribute_methods [ attr_name ]

        class_eval <<-EOV
          def #{attr_name}
            value = read_attribute(:#{attr_name})
            Types::parse_#{type}(value) unless value.nil?
          end

          def #{attr_name}=(value)
            unless value.to_s == read_attribute(value)
              #{attr_name}_will_change!
              write_attribute(:#{attr_name}, value)
            end
          end
        EOV
      end

      def attribute_names
        schema.keys
      end

      def attribute_exists?(attr_name)
        schema.include?(attr_name)
      end

      protected
        def schema
          @schema ||= {}
        end
    end

    def attributes
      @attributes
    end

    protected
      def read_attribute(attr_name)
        @attributes[attr_name]
      end

      def write_attribute(attr_name, value)
        @attributes[attr_name] = value.to_s
      end
  end
end
