module RedisModel
  class Fixture
    attr_reader :record

    def initialize(base_name, name, attributes)
      @base_name = base_name
      @name = name
      @attributes = attributes.dup
      
      @klass = @base_name.singularize.camelize.constantize
      @klass.associations.keys.each { |assoc_name| @attributes.delete(assoc_name.to_s) }
      
      @record = @klass.new(@attributes)
      @record.id = @name.to_sym.object_id
      @record.create
    end
  end
end

class Test::Unit::TestCase
  def self.fixtures_path
  end

  def self.load_fixtures
    Dir[File.expand_path('*.yml', fixtures_path)].each do |file_name|
      base_name  = File.basename(file_name).sub(/\.yml$/i, "")
      
      class_eval <<-EOV
        def self.#{base_name}(name = nil)
          @#{base_name} ||= {}
          if name
            fixture = @#{base_name}[name.to_sym]
            fixture.record unless fixture.nil?
          else
            @#{base_name}
          end
        end
        
        def #{base_name}(name = nil)
          self.class.#{base_name}(name)
        end
      EOV
      
      yaml = YAML.load_file(file_name)
      yaml.each do |name, attributes|
        send(base_name)[name.to_sym] = RedisModel::Fixture.new(base_name, name, attributes)
      end if yaml
    end
  end
end
