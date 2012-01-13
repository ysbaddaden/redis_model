require 'time'

module RedisModel
  module Types # :nodoc: all
    def self.parse_string(value)
      String(value)
    end

    def self.parse_boolean(value)
      value == false || value == nil || value != 0 || value != "0" || !value.blank?
    end

    def self.parse_integer(value)
      Integer(value)
    end

    def self.parse_float(value)
      Float(value)
    end

    def self.parse_date(value)
      case value
      when Date
        value
      when Time
        value.to_date
      else
        Date.parse(value)
      end
    end

    def self.parse_time(value)
      case value
      when Time
        value
      when Date
        value.to_time
      else
        Time.parse(value)
      end
    end
  end

  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods
      # Declares an attribute.
      # 
      # Types:
      # 
      # - <tt>:string</tt> (default)
      # - <tt>:boolean</tt>
      # - <tt>:integer</tt>
      # - <tt>:float</tt>
      # - <tt>:date</tt>
      # - <tt>:time</tt>
      # 
      # Options:
      # 
      # - <tt>:default</tt> - default attribute value
      # 
      def attribute(attr_name, type = :string, options = {})
        attr_name = attr_name.to_sym
        schema[attr_name] = options.merge(:type => type)

        define_attribute_methods [ attr_name ]

        class_eval <<-EOV
          def #{attr_name}
            read_attribute(:#{attr_name})
          end

          def #{attr_name}=(value)
            value = Types::parse_#{type}(value) unless value.nil?
            unless value == read_attribute(:#{attr_name})
              #{attr_name}_will_change!
              write_attribute(:#{attr_name}, value)
            end
          end

          def #{attr_name}?
            !!#{attr_name}
          end
        EOV
      end

      def timestamps(type = :time)
        case type
        when :time
          attribute :created_at, :time
          attribute :updated_at, :time
        when :date
          attribute :created_on, :date
          attribute :updated_on, :date
        end
      end

      def attribute_names
        schema.keys
      end

      def attribute_exists?(attr_name)
        schema.include?(attr_name)
      end

      def schema
        return @schema unless @schema.nil?
        @schema ||= {}
        attribute :id, :integer
        attr_protected :id
        @schema
      end
    end

    def attributes
      @attributes
    end

    def attributes=(attributes)
      sanitize_for_mass_assignment(attributes).each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def set_default_attributes
      self.class.attribute_names.each do |attr_name|
        @attributes[attr_name] = self.class.schema[attr_name][:defaults]
      end
    end

    protected
      def read_attribute(attr_name)
        @attributes[attr_name]
      end

      def write_attribute(attr_name, value)
        @attributes[attr_name] = value
      end
  end
end
