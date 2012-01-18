module RedisModel
  class Fixture
    attr_reader :base_name, :name, :klass, :record, :associations

    def initialize(base_name, name, attributes)
      @base_name = base_name
      @name = name
      @attributes = attributes.dup
      @associations = {}
      
      @klass = @base_name.singularize.camelize.constantize
      @klass.associations.keys.each do |assoc_name|
        fixture_name = @attributes.delete(assoc_name.to_s)
        @associations[assoc_name] = fixture_name unless fixture_name.nil?
      end
      
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
    @fixtures = []
    
    Dir[File.expand_path('*.yml', fixtures_path)].each do |file_name|
      base_name = File.basename(file_name).sub(/\.yml$/i, "")
      @fixtures << base_name
      
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
    
    self.resolve_lazy_fixture_associations
  end

  def self.resolve_lazy_fixture_associations
    @fixtures.each do |base_name|
      send(base_name).values.each do |fixture|
        if fixture.associations.any?
          fixture.associations.each do |assoc_name, fixture_name|
            options = fixture.klass.associations[assoc_name]
            
            case options[:type]
            when :belongs_to
              parent = send(assoc_name.to_s.pluralize, fixture_name)
              parent.send(fixture.base_name) << fixture.record
            else
              raise StandardError.new("Unsupported association type: #{options[:type]}")
            end
          end
        end
      end
    end
  end
end
