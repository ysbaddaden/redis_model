# IMPROVE: Flag a loaded? state for speed-up and optimizations of a bunch of methods.
# IMPROVE: Creating a record should populate the foreign key to children.
# IMPROVE: Saving a record should also save children.
# IMPROVE: Deleting a record should remove it from the parent list!
module RedisModel
  module Associations
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many(name, options = {})
        class_name = options.delete(:class_name) || name.to_s.singularize.camelize
        class_eval <<-EOV
          def #{name}
          end

          def #{name}=
          end
        EOV
      end

      def belongs_to(name, options = {})
        foreign_key = options.delete(:foreign_key) || name.to_s + "_id"
        class_name  = options.delete(:class_name)  || name.to_s.camelize
        attribute(foreign_key, :integer)
        class_eval <<-EOV
          def #{name}
            @#{name} ||= #{class_name}.find(#{foreign_key})
          end

          def #{name}=(parent)
            self.#{foreign_key} = parent.id;
            @#{name} = parent
          end
        EOV
      end
    end
  end
end
