# IMPROVE: Creating a record should populate the foreign key to children.
# IMPROVE: Saving a record should also save children.
# IMPROVE: Deleting a record should remove it from the parent list!
module RedisModel
  module Associations
    extend ActiveSupport::Concern

    module ClassMethods
      def associations
        @associations ||= {}
      end

      def has_many(name, options = {})
        class_name  = options.delete(:class_name)  || name.to_s.singularize.camelize
        foreign_key = options.delete(:foreign_key) || self.model_name.singularize.underscore + "_id"
        
        associations[name.to_sym] = {
          :type        => :has_many,
          :name        => name.to_sym,
          :class_name  => class_name,
          :foreign_key => foreign_key
        }
        
        class_eval <<-EOV
          def #{name}
            Relation.new(:#{name}, #{class_name}, self, :#{foreign_key})
          end

          def #{name}=(records)
            #{name}.clear
            records.each { |record| #{name} << record }
          end
        EOV
      end

      def belongs_to(name, options = {})
        foreign_key = options.delete(:foreign_key) || name.to_s + "_id"
        class_name  = options.delete(:class_name)  || name.to_s.camelize
        
        associations[name.to_sym] = {
          :type        => :belongs_to,
          :name        => name.to_sym,
          :class_name  => class_name,
          :foreign_key => foreign_key
        }
        
        attribute(foreign_key, :integer)
        class_eval <<-EOV
          def #{name}
            @#{name} ||= #{class_name}.find(#{foreign_key})
          end

          def #{name}=(parent)
            self.#{foreign_key} = parent.id
            @#{name} = parent
          end
        EOV
      end
    end
  end
end
